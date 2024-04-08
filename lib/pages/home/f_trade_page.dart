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
  int selectedCategoryIndex = 0; // 0: Imports, 1: Exports, 2: Re-exports
  String? selectedCountry;

  Map<String, double> countryDataImports = {};
  Map<String, double> countryDataExports = {};
  Map<String, double> countryDataReExports = {};

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
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

  Map<String, double> fullDataImports = {};
  Map<String, double> fullDataExports = {};
  Map<String, double> fullDataReExports = {};

  Future<void> fetchFTradeData() async {
    try {
      List<dynamic> countries = await apiService.fetchCountries();

      for (var country in countries) {
        int countryId = country['countryid'];
        String countryName = country['nameenglish'];

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

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CupertinoSegmentedControl<int>(
        children: const {
          0: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Imports'),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Exports'),
          ),
          2: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('Re-exports'),
          ),
        },
        onValueChanged: (int index) {
          setState(() {
            selectedCategoryIndex = index;
          });
        },
        groupValue: selectedCategoryIndex,
        // color properties here
        unselectedColor: const Color.fromARGB(
            255, 245, 252, 255), // Light blue color for unselected segments
        selectedColor:
            Colors.lightBlue, // Lighter blue color for the selected segment
        borderColor:
            const Color.fromARGB(255, 77, 161, 200), // Border color to match
        pressedColor: Colors.lightBlue[100], // Color when a segment is pressed
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foreign Trade Analysis'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchCard(),
            _buildSegmentedControl(),
            const SizedBox(height: 20),
            Text(
              '${[
                "Imports",
                "Exports",
                "Re-exports"
              ][selectedCategoryIndex]} - Summary',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 20),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Search Filters',
              style: TextStyle(
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
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: getSections(fullData),
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

  Widget _buildBarChart() {
    List<BarChartGroupData> barGroups = [];
    int i = 0;
    currentData.forEach((country, value) {
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
            alignment: BarChartAlignment.spaceAround,
            maxY: currentData.isNotEmpty
                ? currentData.values.reduce(max) * 1.2
                : 0,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final String countryName =
                        currentData.keys.elementAt(value.toInt());
                    // Check and replace country name if necessary
                    String displayCountryName = countryName;
                    if (countryName.toUpperCase() == "SAUDI ARABIA") {
                      displayCountryName = "KSA";
                    } else if (countryName.toUpperCase() ==
                        "UNITED ARAB EMIRATES") {
                      displayCountryName = "UAE";
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        displayCountryName,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                  reservedSize: 24,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String formattedValue;
                    if (value >= 1000000000) {
                      formattedValue =
                          '${(value / 1000000000).toStringAsFixed(1)}B';
                    } else if (value >= 1000000) {
                      formattedValue =
                          '${(value / 1000000).toStringAsFixed(1)}M';
                    } else if (value >= 1000) {
                      formattedValue = '${(value / 1000).toStringAsFixed(1)}K';
                    } else {
                      formattedValue = value.toStringAsFixed(0);
                    }
                    return Text(formattedValue,
                        style: const TextStyle(fontSize: 10));
                  },
                  reservedSize: 30,
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(bottom: BorderSide(), left: BorderSide()),
            ),
            gridData: const FlGridData(show: false),
            barGroups: barGroups,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String formattedValue;
                  if (rod.toY >= 1000000000) {
                    formattedValue =
                        '${(rod.toY / 1000000000).toStringAsFixed(1)}B';
                  } else if (rod.toY >= 1000000) {
                    formattedValue =
                        '${(rod.toY / 1000000).toStringAsFixed(1)}M';
                  } else if (rod.toY >= 1000) {
                    formattedValue = '${(rod.toY / 1000).toStringAsFixed(1)}K';
                  } else {
                    formattedValue = rod.toY.toStringAsFixed(0);
                  }
                  return BarTooltipItem(
                    formattedValue,
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> getSections(Map<String, double> dataset) {
    // Define a map of country names and their corresponding colors
    Map<String, Color> countryColors = {
      'BAHRAIN': const Color.fromARGB(255, 255, 190, 180), // Pastel Orange
      'KUWAIT': const Color(0xFFFFE5D6), // Pastel Pink
      'OMAN': const Color.fromARGB(255, 255, 227, 227), // Pastel Blue
      'QATAR': const Color.fromARGB(255, 209, 120, 120), // Pastel Green
      'KSA': const Color.fromARGB(255, 219, 255, 199), // Pastel Red
      'UAE': const Color.fromARGB(255, 169, 169, 169), // Pastel Yellow
    };

    return dataset.entries.map((entry) {
      String countryName = entry.key;
      // Check and replace country name if necessary
      if (countryName.toUpperCase() == "SAUDI ARABIA") {
        countryName = "KSA";
      } else if (countryName.toUpperCase() == "UNITED ARAB EMIRATES") {
        countryName = "UAE";
      }

      final isTouched = countryName == selectedCountry;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;

      // Get the color for the current country, or use a default color if not found
      final color = countryColors[countryName] ?? Colors.grey[300]!;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: countryName,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();
  }
}
