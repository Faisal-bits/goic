import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../models/search_config.dart';
import '../../models/shared_history.dart';
import 'package:intl/intl.dart';
import '../../models/history_notifier.dart';
import 'package:logging/logging.dart';
import 'package:goic/services/api_service.dart';

final Logger logger = Logger('GIDPage');

class CountryData {
  final String name;
  double noOfFirms;
  double investment;
  double noOfLabor;

  CountryData({
    required this.name,
    required this.noOfFirms,
    required this.investment,
    required this.noOfLabor,
  });

  factory CountryData.fromApi(
      Map<String, dynamic> data, Map<int, String> countryIdToNameMap) {
    int countryId = data['countryid'];
    String countryName = countryIdToNameMap[countryId] ?? 'Unknown';

    return CountryData(
      name: countryName, // Now correctly using the country name
      noOfFirms: double.tryParse(data['cnttotfirms'].toString()) ?? 0.0,
      investment: double.tryParse(data['cnttotinvusd'].toString()) ?? 0.0,
      noOfLabor: double.tryParse(data['cnttotmpqty'].toString()) ?? 0.0,
    );
  }
}

List<CountryData> countryDataList = [
  CountryData(
      name: 'Saudi Arabia',
      noOfFirms: 1200,
      investment: 500,
      noOfLabor: 300000),
  CountryData(name: 'UAE', noOfFirms: 900, investment: 450, noOfLabor: 250000),
  CountryData(
      name: 'Qatar', noOfFirms: 700, investment: 300, noOfLabor: 150000),
  CountryData(
      name: 'Kuwait', noOfFirms: 500, investment: 200, noOfLabor: 120000),
  CountryData(name: 'Oman', noOfFirms: 400, investment: 150, noOfLabor: 100000),
  CountryData(
      name: 'Bahrain', noOfFirms: 300, investment: 100, noOfLabor: 80000),
];

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
  Map<int, String> countryIdToNameMap = {};

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

    // Fetch and display the default data
    await fetchGCCSummaryData(); // This should populate the GCC stats card
    await fetchSummaryDataForCountries(); // Fetch detailed data for each country based on default filters
  }

  Future<void> buildCountryIdToNameMap() async {
    List<dynamic> countries = await apiService.fetchCountries();
    for (var country in countries) {
      int countryId = country['countryid'];
      String countryName = country['nameenglish'];
      setState(() {
        countryIdToNameMap[countryId] = countryName;
      });
    }
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
        child: Text(country['nameenglish']),
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

    widget.onSearchDone?.call();
    await saveSearchHistory(currentHistory);
    historyNotifier.notifyListeners();
    await fetchGCCSummaryData();
    await fetchSummaryDataForCountries();
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
    try {
      // Fetch filtered data for the selected filters
      List<dynamic> stats = await apiService.fetchGIDStats(
        year: selectedYear,
        countryId: selectedCountryId,
        isicCode: int.parse(selectedISICSector),
      );

      var processedData = stats
          .map((stat) => CountryData.fromApi(stat, countryIdToNameMap))
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("GID Summary"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Search Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFilters(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "GCC - Summary Stats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGCCSummaryCard(),
            const SizedBox(height: 20),
            _buildHorizontalBarCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
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
                Expanded(child: _buildYearDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildISICDropdown()),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusDropdown()),
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
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
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
      decoration: const InputDecoration(labelText: 'Year'),
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

  Widget _buildISICDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedISICSector,
      decoration: const InputDecoration(labelText: 'ISIC Sector'),
      onChanged: (value) {
        setState(() {
          selectedISICSector = value!;
        });
      },
      items: _isicCodes.map((isicCode) {
        return DropdownMenuItem<String>(
          value: isicCode['isiccode'].toString(),
          child: Text('${isicCode['isiccode']}: ${isicCode['nameenglish']}'),
        );
      }).toList(),
    );
  }

  Widget _buildStatusDropdown() {
    List<String> statuses = ['All', 'Licensed', 'Operational'];
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedStatus,
      decoration: const InputDecoration(labelText: 'Status'),
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

  Widget _buildStatCard(
      String title, double value, String percentage, bool isPositive) {
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

  Widget _buildGCCSummaryCard() {
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
                child: _buildStatCard("No. of Firms", totalFirms,
                    formatPercentage(totalFirms, totalFirms), true)),
            Expanded(
                child: _buildStatCard("Investment (USD)", totalInvestment,
                    formatPercentage(totalInvestment, totalInvestment), true)),
            Expanded(
                child: _buildStatCard("No. of Labor", totalLabor,
                    formatPercentage(totalLabor, totalLabor), true)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          // Wrapping the Text widget with Padding for better spacing
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "GCC - Bar Graphs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: PageView(
            children: [
              _buildBarChart(
                title: "No. of Firms",
                dataSelector: (CountryData data) => data.noOfFirms,
                barColor: Colors.lightBlue,
              ),
              _buildBarChart(
                title: "Investment (USD Mill)",
                dataSelector: (CountryData data) => data.investment,
                barColor: Colors.greenAccent,
              ),
              _buildBarChart(
                title: "No. of Labor",
                dataSelector: (CountryData data) => data.noOfLabor,
                barColor: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> fetchSummaryDataForCountries() async {
    Map<int, String> countryNames =
        {}; // Map to hold country IDs and their names
    // Populate countryNames with the country ID and name
    _countries.forEach((country) {
      countryNames[country['countryid']] = country['nameenglish'];
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
                CountryData.fromApi(data, countryIdToNameMap);
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
  }) {
    // Check if countryDataList is empty and return an empty widget or placeholder.
    if (countryDataList.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Center(child: Text('No data available')),
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
