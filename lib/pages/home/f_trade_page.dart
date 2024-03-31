import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:logging/logging.dart';

final Logger logger = Logger('FTrade');

class FTradePage extends StatefulWidget {
  final int? year;
  final String tradeType;
  const FTradePage({Key? key, this.year, this.tradeType = 'Imports'})
      : super(key: key);

  @override
  State<FTradePage> createState() => _FTradePageState();
}

class _FTradePageState extends State<FTradePage> {
  int selectedYear = DateTime.now().year;
  String selectedProduct = 'All';
  int selectedCategoryIndex = 0; // 0: Imports, 1: Exports, 2: Re-exports

  @override
  void initState() {
    super.initState();
    selectedYear = widget.year ?? DateTime.now().year;
    switch (widget.tradeType.toLowerCase()) {
      case 'export':
        selectedCategoryIndex = 1;
        break;
      case 're-export':
        selectedCategoryIndex = 2;
        break;
      case 'import':
      default:
        selectedCategoryIndex = 0;
        break;
    }
  }

  final Map<String, double> countryDataImports = {
    'Saudi Arabia': 20,
    'UAE': 25,
    'Qatar': 15,
    'Kuwait': 10,
    'Oman': 5,
    'Bahrain': 3,
  };
  final Map<String, double> countryDataExports = {
    'Saudi Arabia': 30,
    'UAE': 20,
    'Qatar': 25,
    'Kuwait': 15,
    'Oman': 10,
    'Bahrain': 5,
  };
  final Map<String, double> countryDataReExports = {
    'Saudi Arabia': 5,
    'UAE': 15,
    'Qatar': 20,
    'Kuwait': 25,
    'Oman': 30,
    'Bahrain': 35,
  };

  Map<String, double> get currentData => [
        countryDataImports,
        countryDataExports,
        countryDataReExports,
      ][selectedCategoryIndex];

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
                color: Colors.black45, // Light gray color for the text
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.grey[50], // Light gray color for the card background
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Year'),
                        value: selectedYear,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                        },
                        items: List.generate(5, (index) {
                          return DropdownMenuItem(
                            value: DateTime.now().year - index,
                            child: Text('${DateTime.now().year - index}'),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Product'),
                        value: selectedProduct,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedProduct = newValue!;
                          });
                        },
                        items: <String>[
                          'All',
                          'Product 1',
                          'Product 2',
                          'Product 3'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // search functionality
                    logger.info('Search clicked');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Blue color for the search button
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
          sections: getSections(currentData), // current dataset
          centerSpaceRadius: 60,
          sectionsSpace: 2,
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
            BarChartRodData(toY: value, color: Colors.blue),
          ],
          showingTooltipIndicators: [0],
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
            maxY: currentData.values.reduce(max) * 1.2,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        currentData.keys.elementAt(value.toInt()),
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
                    return Text(value.toString(),
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
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> getSections(Map<String, double> dataset) {
    return dataset.entries.map((entry) {
      return PieChartSectionData(
        color: Colors.blue[100 * (entry.key.length % 5 + 1)],
        value: entry.value,
        title: entry.key,
        radius: 100,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
      );
    }).toList();
  }
}
