import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SocioEconomicResultPage extends StatefulWidget {
  final String country;
  final String economicIndicator;
  final String industrialIndicator;

  const SocioEconomicResultPage({
    Key? key,
    required this.country,
    required this.economicIndicator,
    required this.industrialIndicator,
  }) : super(key: key);

  @override
  _SocioEconomicResultPageState createState() =>
      _SocioEconomicResultPageState();
}

class _SocioEconomicResultPageState extends State<SocioEconomicResultPage> {
  @override
  void initState() {
    super.initState();
    selectedEconomicIndicator = widget.economicIndicator;
    selectedIndustrialIndicator = widget.industrialIndicator;
  }

  // Sample data for economic indicators over the past 5 years for a country
  final Map<String, List<double>> sampleEconomicData = {
    'GDP': [1000, 1200, 1400, 1600, 1800],
    'Inflation': [2.5, 3.0, 1.8, 2.1, 2.3],
    'Unemployment': [5.0, 4.8, 4.6, 4.2, 3.9],
  };

  // Sample data for industrial indicators
  final Map<String, List<double>> sampleIndustrialData = {
    'Manufacturing': [500, 550, 600, 650, 700],
    'Construction': [300, 320, 340, 360, 380],
    'Services': [800, 850, 900, 950, 1000],
  };

  // Current selected indicators
  String selectedEconomicIndicator = 'GDP';
  String selectedIndustrialIndicator = 'Manufacturing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('${widget.country} - Socio-Economic Analysis')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildIndicatorDropdown(
              'Economic Indicator',
              sampleEconomicData.keys.toList(),
              selectedEconomicIndicator,
              (newValue) {
                if (newValue != null) {
                  // Check if newValue is not null
                  setState(() {
                    selectedEconomicIndicator =
                        newValue; // Safely assign the non-null newValue to the state variable
                  });
                }
              },
            ),
            _buildBarChart(sampleEconomicData[selectedEconomicIndicator]!),
            _buildIndicatorDropdown(
              'Industrial Indicator',
              sampleIndustrialData.keys.toList(),
              selectedIndustrialIndicator,
              (newValue) {
                if (newValue != null) {
                  // Check if newValue is not null
                  setState(() {
                    selectedIndustrialIndicator =
                        newValue; // Safely assign the non-null newValue to the state variable
                  });
                }
              },
            ),
            _buildBarChart(sampleIndustrialData[selectedIndustrialIndicator]!),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDropdown(String title, List<String> options,
      String selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: selectedValue,
            onChanged: (newValue) {
              // Since newValue is nullable, we need to check for null.
              // If newValue is not null, then we can safely pass it to the callback.
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: data.reduce(
                    (value, element) => value > element ? value : element) *
                1.2,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final year = DateTime.now().year - 4 + value.toInt();
                    return Text(year.toString(),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold));
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, // Enable the Y-axis labels on the left
                  getTitlesWidget: (value, meta) {
                    // This function determines the widget to display for each Y-axis title
                    return Text('${value.toInt()}',
                        style: TextStyle(color: Colors.black, fontSize: 10));
                  },
                  reservedSize:
                      40, // Adjust this value as needed to fit your labels
                ),
              ),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
                show: false), // Set this to false to remove grid lines
            barGroups: List.generate(data.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data[index],
                    color: Colors.blue,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
