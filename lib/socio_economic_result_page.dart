import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SocioEconomicResultPage extends StatelessWidget {
  final String country;
  final String economicIndicator;

  SocioEconomicResultPage(this.country, this.economicIndicator);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$country - $economicIndicator')),
      body: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                  // Dummy data, replace with actual data based on parameters
                  // For economicIndicator chart
                  ),
            ),
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                  // Dummy data, replace with actual data for industrial indicators
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
