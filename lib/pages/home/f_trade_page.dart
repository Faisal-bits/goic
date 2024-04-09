import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:goic/services/api_service.dart';
import 'package:goic/models/search_config.dart';
import '../../models/history_notifier.dart';
import 'package:intl/intl.dart';
import 'package:goic/models/shared_history.dart';
import 'package:goic/localization.dart';
import 'dart:async';

final Logger logger = Logger('FTrade');

class FTradePage extends StatefulWidget {
  final int? year;
  final int initialCategoryIndex;

  const FTradePage({Key? key, this.year, this.initialCategoryIndex = 0})
      : super(key: key);

  @override
  State<FTradePage> createState() => _FTradePageState();
}

class _FTradePageState extends State<FTradePage> {
  int selectedYear = DateTime.now().year - 1;
  String selectedProduct = 'All';
  int selectedCategoryIndex = 0;
  String? selectedCountry;

  Map<String, double> countryDataImports = {};
  Map<String, double> countryDataExports = {};
  Map<String, double> countryDataReExports = {};

  Map<String, double> fullDataImports = {};
  Map<String, double> fullDataExports = {};
  Map<String, double> fullDataReExports = {};

  ApiService apiService = ApiService();

  final _dataLoadingStream = StreamController<bool>.broadcast();

  _FTradePageState() {
    countryDataImports = {};
    countryDataExports = {};
    countryDataReExports = {};
  }

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    selectedYear = widget.year ?? (currentYear - 1);
    selectedCategoryIndex = widget.initialCategoryIndex;

    selectedYear = widget.year ?? (currentYear - 1);
    selectedCategoryIndex = widget.initialCategoryIndex;

    // Ensure selectedYear is within the valid range
    if (selectedYear > currentYear - 1) {
      selectedYear = currentYear - 1;
    } else if (selectedYear < currentYear - 5) {
      selectedYear = currentYear - 5;
    }

    fetchFTradeData();
  }

  Future<void> fetchFTradeData() async {
    try {
      List<dynamic> countries = await apiService.fetchCountries();

      for (var country in countries) {
        int countryId = country['countryid'];
        String countryName;
        if (!mounted) return;
        if (Localizations.localeOf(context).languageCode == 'en') {
          countryName = country['nameenglish'];
        } else {
          countryName = country['namearabic'];
        }

        // Exclude the country with ID 10096 (GCC)
        if (countryId == 10096) {
          continue;
        }

        List<dynamic> fTradeData = await apiService.fetchFTradeData(
          year: selectedYear,
          countryId: countryId,
        );

        if (fTradeData.isNotEmpty) {
          var data = fTradeData.first;
          setState(() {
            fullDataImports[countryName] = double.parse(data['cntimportusd']);
            fullDataExports[countryName] = double.parse(data['cntexportusd']);
            fullDataReExports[countryName] =
                double.parse(data['cntreexportusd']);

            countryDataImports[countryName] =
                double.parse(data['cntimportusd']);
            countryDataExports[countryName] =
                double.parse(data['cntexportusd']);
            countryDataReExports[countryName] =
                double.parse(data['cntreexportusd']);
          });
        }
      }
    } catch (e) {
      logger.severe('Failed to fetch FTrade data: $e');
    }

    _dataLoadingStream.sink.add(true);
  }

  Map<String, double> get fullData {
    return [
      fullDataImports,
      fullDataExports,
      fullDataReExports,
    ][selectedCategoryIndex];
  }

  Map<String, double> get currentData {
    if (selectedCountry != null) {
      return {
        selectedCountry!: [
              countryDataImports,
              countryDataExports,
              countryDataReExports,
            ][selectedCategoryIndex][selectedCountry] ??
            0.0,
      };
    }
    return [
      countryDataImports,
      countryDataExports,
      countryDataReExports,
    ][selectedCategoryIndex];
  }

  void _onPieChartSectionTapped(PieTouchResponse pieTouchResponse) {
    if (pieTouchResponse.touchedSection != null) {
      final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
      if (touchedIndex >= 0 && touchedIndex < currentData.keys.length) {
        final country = currentData.keys.elementAt(touchedIndex);
        setState(() {
          if (selectedCountry == country) {
            selectedCountry = null;
          } else {
            selectedCountry = country;
          }
        });
      }
    }
  }

  Widget _buildSegmentedControl(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CupertinoSegmentedControl<int>(
        children: {
          0: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(localizations.imports),
          ),
          1: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(localizations.exports),
          ),
          2: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(localizations.reExport),
          ),
        },
        onValueChanged: (int index) {
          setState(() {
            selectedCategoryIndex = index;
          });
        },
        groupValue: selectedCategoryIndex,
        selectedColor:
            Colors.blue, // Set selected segment background color to blue
        unselectedColor: Colors
            .white, // Optionally, set unselected segments to a different color
        borderColor: Colors
            .blue, // Optionally, match the border color with the selected color
        pressedColor: Colors.blue
            .withOpacity(0.5), // Optional, for visual feedback on press
      ),
    );
  }

  void _onSearchPressed() async {
    final newSearchConfig = FTradeSearchConfig(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      year: selectedYear,
      tradeType: [
        'Imports',
        'Exports',
        'Re-exports',
      ][selectedCategoryIndex],
    );

    List<FTradeSearchConfig> currentHistory = await loadFTradeSearchHistory();
    currentHistory.add(newSearchConfig);
    await saveFTradeSearchHistory(currentHistory);

    HistoryNotifier().notifyListeners();
    fetchFTradeData();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.fTrade),
      ),
      body: StreamBuilder<bool>(
        stream: _dataLoadingStream.stream,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchCard(localizations),
                  _buildSegmentedControl(localizations),
                  const SizedBox(height: 20),
                  Text(
                    '${[
                      localizations.imports,
                      localizations.exports,
                      localizations.reExport,
                    ][selectedCategoryIndex]} - ${localizations.summary}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildPieChart(localizations),
                  const SizedBox(height: 20),
                  _buildBarChart(localizations),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _dataLoadingStream.close();
    super.dispose();
  }

  Widget _buildSearchCard(AppLocalizations localizations) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              localizations.searchFilters, // Localized
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Year'),
                  value: selectedYear,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedYear = newValue!;
                    });
                  },
                  items: List<DropdownMenuItem<int>>.generate(
                    5,
                    (index) {
                      int year = DateTime.now().year - 1 - index;
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onSearchPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    localizations.search,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(AppLocalizations localizations) {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: getSections(fullData, localizations),
          centerSpaceRadius: 60,
          sectionsSpace: 2,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (event is FlTapUpEvent && pieTouchResponse != null) {
                _onPieChartSectionTapped(pieTouchResponse);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(AppLocalizations localizations) {
    List<BarChartGroupData> barGroups = [];
    int i = 0;
    currentData.forEach((country, value) {
      String displayCountryName =
          country; // Default to using the country name directly
      if (country == "SAUDI ARABIA") {
        displayCountryName = "KSA";
      } else if (country == "UNITED ARAB EMIRATES") {
        displayCountryName = "UAE";
      } else {
        displayCountryName = localizations.getCountryName(country);
      }

      barGroups.add(
        BarChartGroupData(
          x: i++,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.blue,
              width: 22,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: currentData.values.reduce(max) * 1.2,
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            maxY: currentData.values.reduce(max) * 1.2,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < currentData.keys.length) {
                      String country = currentData.keys.elementAt(index);
                      String displayCountryName =
                          country; // Re-declare inside the scope
                      if (country == "SAUDI ARABIA") {
                        displayCountryName = "KSA";
                      } else if (country == "UNITED ARAB EMIRATES") {
                        displayCountryName = "UAE";
                      } else {
                        displayCountryName =
                            localizations.getCountryName(country);
                      }
                      return Text(
                        displayCountryName,
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 35,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value == 0 ? '0' : '${formatNumber(value)}',
                        style: const TextStyle(fontSize: 10));
                  },
                  reservedSize: 40,
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(),
                left: BorderSide(),
              ),
            ),
            gridData: const FlGridData(show: false),
            barGroups: barGroups,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final formattedValue = formatNumber(rod.toY);
                  return BarTooltipItem(
                    formattedValue,
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {},
            ),
          ),
        ),
      ),
    );
  }

  String formatNumber(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(1)}B';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  List<PieChartSectionData> getSections(
      Map<String, double> dataset, AppLocalizations localizations) {
    // Define a map of country names and their corresponding colors
    Map<String, Color> countryColors = {
      'BAHRAIN': const Color(0xFFF76C5E), // Light red
      'KUWAIT': const Color(0xFF93C572), // Light green
      'OMAN': const Color(0xFFF9A602), // Light orange
      'QATAR': const Color(0xFFD98880), // Light maroon
      'SAUDI ARABIA': const Color(0xFF82E0AA), // Light green
      'UNITED ARAB EMIRATES': const Color(0xFFD7DBDD), // Light gray
      'البحرين': const Color(0xFFF76C5E), // Light red
      'الكويت': const Color(0xFF93C572), // Light green
      'عمان': const Color(0xFFF9A602), // Light orange
      'قطر': const Color(0xFFD98880), // Light maroon
    };

    return dataset.entries.map((entry) {
      String countryName = entry.key;
      // Localize the country name
      String localizedCountryName = localizations.getCountryName(countryName);

      final isTouched = countryName == selectedCountry;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;

      // Get the color for the current country, or use a default color if not found
      final color = countryColors[countryName.toUpperCase()] ??
          (countryName.toUpperCase() == 'SAUDI ARABIA'
              ? const Color(0xFF82E0AA)
              : (countryName.toUpperCase() == 'UNITED ARAB EMIRATES'
                  ? const Color(0xFFD7DBDD)
                  : Colors.grey[300]!));

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: localizedCountryName, // Use the localized name here
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();
  }
}
