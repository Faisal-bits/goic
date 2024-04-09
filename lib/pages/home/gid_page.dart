import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../models/search_config.dart';
import '../../models/shared_history.dart';
import 'package:intl/intl.dart';
import '../../models/history_notifier.dart';
import 'package:logging/logging.dart';
import 'package:goic/services/api_service.dart';
import 'package:goic/localization.dart';

final Logger logger = Logger('GIDPage');

class CountryData {
  final int id;
  final String name;
  double noOfFirms;
  double investment;
  double noOfLabor;

  CountryData({
    required this.id,
    required this.name,
    required this.noOfFirms,
    required this.investment,
    required this.noOfLabor,
  });

  // Update the factory constructor to assign the countryId to the id property
  factory CountryData.fromApi(
      Map<String, dynamic> data,
      Map<int, Map<String, String>> countryIdToNameMap,
      AppLocalizations localizations) {
    int countryId = data['countryid'];
    Map<String, String>? names = countryIdToNameMap[countryId];
    String countryName = 'Unknown'; // Default value

    if (names != null) {
      countryName = localizations.locale.languageCode == 'en'
          ? names['en'] ?? 'Unknown'
          : names['ar'] ?? 'Unknown';
    }

    return CountryData(
      id: countryId,
      name: countryName,
      noOfFirms: double.tryParse(data['cnttotfirms'].toString()) ?? 0.0,
      investment: double.tryParse(data['cnttotinvusd'].toString()) ?? 0.0,
      noOfLabor: double.tryParse(data['cnttotmpqty'].toString()) ?? 0.0,
    );
  }
}

List<CountryData> countryDataList = [];

class GIDPage extends StatefulWidget {
  final SearchConfig? initialConfig;
  final VoidCallback? onSearchDone;

  const GIDPage({Key? key, this.initialConfig, this.onSearchDone})
      : super(key: key);

  @override
  State<GIDPage> createState() => _GIDPageState();
}

class _GIDPageState extends State<GIDPage> {
  late int selectedYear;
  late String selectedISICSector;
  late String selectedStatus;
  HistoryNotifier historyNotifier = HistoryNotifier();
  List<dynamic> _countries = [];
  List<dynamic> _isicCodes = [];
  List<dynamic> _companyStatuses = [];
  double totalFirms = 0;
  double totalInvestment = 0;
  double totalLabor = 0;
  late int selectedCountryId;
  Map<int, Map<String, String>> countryIdToNameMap = {};

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    bool isAfterSeptember = DateTime.now().month > 9;
    selectedYear =
        isAfterSeptember ? DateTime.now().year : DateTime.now().year - 1;

    selectedISICSector =
        widget.initialConfig?.isic ?? '10'; // adjust this based on API data
    selectedStatus =
        widget.initialConfig?.status ?? 'All'; // Adjust based on API data
    selectedCountryId =
        _countries.isNotEmpty ? _countries.first['countryid'] : 0;

    initializePageData();
  }

  Future<void> initializePageData() async {
    // Fetch necessary initial data such as countries, ISIC codes, etc.
    await Future.wait([
      apiService.fetchCountries(),
      apiService.fetchISICCodes(),
      apiService.fetchCompanyStatuses(),
    ]).then((responses) {
      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        _countries = responses[0];
        _isicCodes = responses[1];
        _companyStatuses = responses[2];
        selectedCountryId = _countries.isNotEmpty
            ? int.parse(_countries.first['countryid'].toString())
            : 0;
      });
    });

    // Build the country ID to name map
    await buildCountryIdToNameMap();

    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;

    // Fetch and display the default data
    await fetchGCCSummaryData(); // This should populate the GCC stats card
    await fetchSummaryDataForCountries(
        localizations); // Fetch detailed data for each country based on default filters
  }

  Future<void> buildCountryIdToNameMap() async {
    List<dynamic> countries = await apiService.fetchCountries();
    Map<int, Map<String, String>> countryIdToNameMap = {};

    for (var country in countries) {
      int countryId = country['countryid'];
      String englishName = country['nameenglish'] ?? 'Unknown';
      String arabicName = country['namearabic'] ?? 'Unknown';

      countryIdToNameMap[countryId] = {
        'en': englishName,
        'ar': arabicName,
      };
    }

    setState(() {
      this.countryIdToNameMap = countryIdToNameMap;
    });
  }

  Future<void> fetchGCCSummaryData() async {
    int gccCountryId = 10096; // GCC country ID
    List<int> filteredStatusIds = [];
    if (selectedStatus == 'Licensed') {
      filteredStatusIds.add(4); // Assuming 4 is the ID for Licensed
    } else if (selectedStatus == 'Operational') {
      filteredStatusIds.add(5); // Assuming 5 is the ID for Operational
    }
    // No need to add anything if "All" is selected, as we want to include all statuses.

    try {
      // Fetch data for the selected year
      List<dynamic> currentYearStats = await apiService.fetchGIDStats(
          year: selectedYear,
          countryId: gccCountryId,
          isicCode: int.parse(selectedISICSector));

      double firmsCurrentYear = 0,
          investmentCurrentYear = 0,
          laborCurrentYear = 0;

      // Filter and summarize current year stats based on status
      currentYearStats.forEach((stat) {
        int statusId = stat['companystatusid'];
        if (filteredStatusIds.isEmpty || filteredStatusIds.contains(statusId)) {
          firmsCurrentYear +=
              double.tryParse(stat['gcctotfirms'].toString()) ?? 0;
          investmentCurrentYear +=
              double.tryParse(stat['gcctotinvusd'].toString()) ?? 0;
          laborCurrentYear +=
              double.tryParse(stat['gcctotmpqty'].toString()) ?? 0;
        }
      });

      // If not the current year, fetch and summarize previous year stats for comparison
      // Note: You might want to apply similar filtering logic for the previous year stats

      // Update state with fetched data
      setState(() {
        totalFirms = firmsCurrentYear;
        totalInvestment = investmentCurrentYear;
        totalLabor = laborCurrentYear;
        // If you have variables for percentage changes, update them here as needed
      });
    } catch (e) {
      logger.severe("Failed to fetch GCC summary data: $e");
    }
  }

  void fetchSummaryData() async {
    try {
      List<dynamic> summaryStats = await apiService.fetchGIDStats(
          year: selectedYear, countryId: selectedCountryId);

      setState(() {
        totalFirms = summaryStats.fold<double>(
            0,
            (sum, data) =>
                sum + (double.tryParse(data['noOfFirms'].toString()) ?? 0.0));
        totalInvestment = summaryStats.fold<double>(
            0,
            (sum, data) =>
                sum + (double.tryParse(data['investment'].toString()) ?? 0.0));
        totalLabor = summaryStats.fold<double>(
            0,
            (sum, data) =>
                sum + (double.tryParse(data['noOfLabor'].toString()) ?? 0.0));
      });
    } catch (e) {
      logger.severe("Failed to fetch summary data: $e");
    }
  }

  List<DropdownMenuItem<String>> getCountryItems() {
    return _countries.map<DropdownMenuItem<String>>((country) {
      return DropdownMenuItem<String>(
        value: country['countryid'].toString(),
        child: Text(country['namearabic']),
      );
    }).toList();
  }

  void _onSearchPressed() async {
    final newSearchConfig = SearchConfig(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      year: selectedYear,
      isic: selectedISICSector,
      status: selectedStatus,
    );

    // Load the current history, add the new search, and save it
    List<SearchConfig> currentHistory = await loadSearchHistory();
    currentHistory.add(newSearchConfig);
    await saveSearchHistory(currentHistory);

    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;

    widget.onSearchDone?.call();
    await saveSearchHistory(currentHistory);
    historyNotifier.notifyListeners();
    await fetchGCCSummaryData();
    await fetchSummaryDataForCountries(localizations);
  }

  void updateSummaryAndGraphs(List<CountryData> data) {
    // Calculate summary stats
    final totalFirms =
        data.fold<double>(0, (sum, item) => sum + item.noOfFirms);
    final totalInvestment =
        data.fold<double>(0, (sum, item) => sum + item.investment);
    final totalLabor =
        data.fold<double>(0, (sum, item) => sum + item.noOfLabor);

    // Update state to refresh UI with new data
    setState(() {
      // Assuming variables to hold summary stats
      this.totalFirms = totalFirms;
      this.totalInvestment = totalInvestment;
      this.totalLabor = totalLabor;
    });
  }

  void filterData() async {
    final ApiService apiService = ApiService();
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    try {
      // Fetch filtered data for the selected filters
      List<dynamic> stats = await apiService.fetchGIDStats(
        year: selectedYear,
        countryId: selectedCountryId,
        isicCode: int.parse(selectedISICSector),
      );

      var processedData = stats
          .map((stat) =>
              CountryData.fromApi(stat, countryIdToNameMap, localizations))
          .toList();

      setState(() {
        countryDataList = processedData;
        // Trigger any other UI updates needed based on new data
      });

      // Call additional methods here if you need to further process data for the summary or graphs
      updateSummaryAndGraphs(processedData);
    } catch (e) {
      logger.severe("Failed to fetch filtered data: $e");
      // Handle errors, maybe show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.gid),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                localizations.searchFilters,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFilters(localizations),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                localizations.gccSummaryStats,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGCCSummaryCard(localizations),
            const SizedBox(height: 20),
            _buildHorizontalBarCharts(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations localizations) {
    return Card(
      // color: Colors.grey[100], // the card's background color to light gray
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildYearDropdown(localizations)),
                const SizedBox(width: 8),
                Expanded(child: _buildISICDropdown(localizations)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusDropdown(localizations)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                filterData();
                _onSearchPressed();
                logger.info(
                    'Filters applied: Year: $selectedYear, ISIC: $selectedISICSector, Status: $selectedStatus');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.search),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown(AppLocalizations localizations) {
    int currentYear = DateTime.now().year;
    // Check if the current month is after September
    bool isAfterSeptember = DateTime.now().month > 9;
    // If it's after September, use the current year as the starting year
    // Otherwise, use the previous year as the starting year
    int startingYear = isAfterSeptember ? currentYear : currentYear - 1;

    List<int> years = List.generate(5, (index) => startingYear - index);
    return DropdownButtonFormField<int>(
      isExpanded: true,
      value: selectedYear,
      decoration: InputDecoration(labelText: localizations.year),
      onChanged: (value) {
        setState(() {
          selectedYear = value!;
        });
      },
      items: years.map<DropdownMenuItem<int>>((year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildISICDropdown(AppLocalizations localizations) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedISICSector,
      decoration: InputDecoration(labelText: localizations.isicSector),
      onChanged: (value) {
        setState(() {
          selectedISICSector = value!;
        });
      },
      items: _isicCodes.map((isicCode) {
        final String isicName = localizations.locale.languageCode == 'en'
            ? isicCode['nameenglish']
            : isicCode['namearabic'];
        return DropdownMenuItem<String>(
          value: isicCode['isiccode'].toString(),
          child: Text('${isicCode['isiccode']}: $isicName'),
        );
      }).toList(),
    );
  }

  Widget _buildStatusDropdown(AppLocalizations localizations) {
    List<String> statuses = [
      localizations.all,
      localizations.licensed,
      localizations.operational,
    ];

    // Set the initial value of selectedStatus to the localized "all" value
    if (!statuses.contains(selectedStatus)) {
      selectedStatus = localizations.all;
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedStatus,
      decoration: InputDecoration(labelText: localizations.status),
      onChanged: (value) {
        setState(() {
          selectedStatus = value!;
        });
      },
      items: statuses.map<DropdownMenuItem<String>>((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String title, double value, String percentage,
      bool isPositive, AppLocalizations localizations) {
    // Use _formatNumber within this method to handle the value formatting
    String formattedValue = _formatNumber(value);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              formattedValue,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              percentage,
              style: TextStyle(color: isPositive ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000 && value < 1000000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 1000000 && value < 1000000000) {
      // For values in millions, show with one decimal point for precision
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000000) {
      // For values in billions, show with one decimal point for precision
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    return value.toStringAsFixed(0);
  }

  String formatPercentage(double value, double total) {
    if (total == 0) return "N/A"; // Prevent division by zero
    double percentage = value / total * 100;
    return "${percentage.toStringAsFixed(1)}%";
  }

  Widget _buildGCCSummaryCard(AppLocalizations localizations) {
    // The method uses totalFirms, totalInvestment, and totalLabor directly
    // These variables are updated by fetchSummaryData based on API response
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: _buildStatCard(
                    localizations.noOfFirms,
                    totalFirms,
                    formatPercentage(totalFirms, totalFirms),
                    true,
                    localizations)),
            Expanded(
                child: _buildStatCard(
                    localizations.investmentUSD,
                    totalInvestment,
                    formatPercentage(totalInvestment, totalInvestment),
                    true,
                    localizations)),
            Expanded(
                child: _buildStatCard(
                    localizations.noOfLabor,
                    totalLabor,
                    formatPercentage(totalLabor, totalLabor),
                    true,
                    localizations)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarCharts(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Wrapping the Text widget with Padding for better spacing
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            localizations.gccBarGraphs,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: PageView(
            children: [
              _buildBarChart(
                title: localizations.noOfFirms,
                dataSelector: (CountryData data) => data.noOfFirms,
                barColor: Colors.lightBlue,
                localizations: localizations,
              ),
              _buildBarChart(
                title: localizations.investmentUSDMill,
                dataSelector: (CountryData data) => data.investment,
                barColor: Colors.greenAccent,
                localizations: localizations,
              ),
              _buildBarChart(
                title: localizations.noOfLabor,
                dataSelector: (CountryData data) => data.noOfLabor,
                barColor: Colors.orangeAccent,
                localizations: localizations,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> fetchSummaryDataForCountries(
      AppLocalizations localizations) async {
    Map<int, String> countryNames =
        {}; // Map to hold country IDs and their names
    // Populate countryNames with the country ID and name
    _countries.forEach((country) {
      countryNames[country['countryid']] =
          localizations.locale.languageCode == 'en'
              ? country['nameenglish']
              : country['namearabic'];
    });

    List<int> countryIds = [
      10012,
      10108,
      10136,
      10168,
      10181,
      10207,
    ];
    Map<String, CountryData> fetchedDataMap = {};

    List<int> filteredStatusIds = [];
    if (selectedStatus == 'Licensed') {
      filteredStatusIds.add(4); // Assuming 4 is the ID for Licensed
    } else if (selectedStatus == 'Operational') {
      filteredStatusIds.add(5); // Assuming 5 is the ID for Operational
    } else {
      // If "All" is selected, include both
      filteredStatusIds.addAll([4, 5]);
    }

    for (int countryId in countryIds) {
      try {
        List<dynamic> summaryStats = await apiService.fetchGIDStats(
          year: selectedYear,
          countryId: countryId,
          isicCode: int.parse(selectedISICSector),
        );

        // Process each entry in the summary stats
        summaryStats.forEach((data) {
          int statusId = data['companystatusid'];
          String countryName = countryNames[data['countryid']] ?? 'Unknown';
          if (filteredStatusIds.isEmpty ||
              filteredStatusIds.contains(statusId)) {
            fetchedDataMap[countryName] =
                CountryData.fromApi(data, countryIdToNameMap, localizations);
          } else {
            // Merge data for company statuses 4 and 5
            fetchedDataMap[countryName]!.noOfFirms +=
                double.tryParse(data['cnttotfirms'].toString()) ?? 0.0;
            fetchedDataMap[countryName]!.investment +=
                double.tryParse(data['cnttotinvusd'].toString()) ?? 0.0;
            fetchedDataMap[countryName]!.noOfLabor +=
                double.tryParse(data['cnttotmpqty'].toString()) ?? 0.0;
          }
        });
      } catch (e, stacktrace) {
        logger.severe(
            "Failed to fetch summary data for country ID $countryId: $e",
            e,
            stacktrace);
      }
    }

    // Convert the map back to a list for easy use with charting libraries
    List<CountryData> fetchedDataList = fetchedDataMap.values.toList();

    setState(() {
      countryDataList = fetchedDataList;
    });
  }

  String formatAxisValue(double value) {
    if (value >= 1000 && value < 10000) {
      // For values between 1K and 9.999K, include one decimal point
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 10000 && value < 1000000) {
      // For values 10K and above, show without decimal points until it reaches a million
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else if (value >= 1000000 && value < 1000000000) {
      // For values in millions, show with one decimal point for precision
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000000) {
      // For values in billions, show with one decimal point for precision
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildBarChart({
    required String title,
    required double Function(CountryData) dataSelector,
    required Color barColor,
    required AppLocalizations localizations,
  }) {
    // Check if countryDataList is empty and return an empty widget or placeholder.
    if (countryDataList.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: Text(localizations.noDataAvailable)),
      );
    }

    final maxY = countryDataList.map(dataSelector).reduce(max) * 1.15;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                gridData: const FlGridData(show: false),
                barGroups: countryDataList.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry
                        .key, // This should match the index in countryDataList
                    barRods: [
                      BarChartRodData(
                        toY: dataSelector(entry.value),
                        color: barColor,
                        borderRadius: BorderRadius.zero,
                      )
                    ],
                  );
                }).toList(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(4),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final countryName = countryDataList[group.x].name;
                      return BarTooltipItem(
                        '$countryName: ${formatAxisValue(rod.toY)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < countryDataList.length) {
                          String countryName = countryDataList[index].name;

                          // Check for specific country names and replace them with abbreviations
                          if (countryName == "SAUDI ARABIA") {
                            countryName = "KSA";
                          } else if (countryName == "UNITED ARAB EMIRATES") {
                            countryName = "UAE";
                          } else if (countryName ==
                              "المملكة العربية السعودية") {
                            countryName = "السعودية";
                          } else if (countryName ==
                              "الامارات العربية المتحدة") {
                            countryName = "الإمارات";
                          }

                          return Text(
                            countryName,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10),
                            textAlign: TextAlign.center,
                          );
                        }
                        return const Text('');
                      },
                      reservedSize:
                          40, // Adjust based on the size of the labels
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                          formatAxisValue(value),
                          style: const TextStyle(
                              color: Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
