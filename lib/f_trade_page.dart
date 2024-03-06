import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FTradePage extends StatefulWidget {
  @override
  _FTradePageState createState() => _FTradePageState();
}

class _FTradePageState extends State<FTradePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F Trade'),
      ),
      body: Container(
        height:
            MediaQuery.of(context).size.height, // Take full height of device
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCategoryPage('Imports'),
            _buildCategoryPage('Exports'),
            _buildCategoryPage('Re-exports'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPage(String category) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(category,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          _buildPieChart(),
          _buildLineChart(),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    // Dummy Pie Chart
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 10, title: 'Country 1', color: Colors.red),
          PieChartSectionData(
              value: 15, title: 'Country 2', color: Colors.blue),
          // Add more sections as needed
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    // Corrected Line Chart
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 3),
              // Continue adding FlSpot instances for more data points
            ],
            isCurved: true,
            color: Colors.green, // Corrected usage
            barWidth: 2, // Example width, adjust as needed
            dotData: FlDotData(show: false), // Optionally hide or style dots
          ),
        ],
        // Continue configuring your LineChartData as needed
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 8, // This is the required 'toY' parameter.
                color: Colors.orange, // Use 'color' for a solid color
                width: 22, // Example width, adjust as needed
                // If you need a gradient instead of a solid color, use the 'gradient' parameter
                // gradient: LinearGradient(
                //   colors: [Colors.orange, Colors.red],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
                borderRadius:
                    BorderRadius.circular(0), // Adjust corner radius if needed
              ),
              // Add more BarChartRodData instances for additional bars
            ],
            // Optionally adjust group space, rod width, etc.
          ),
          // Add more BarChartGroupData instances for additional groups
        ],
        // Continue configuring your BarChartData as needed
      ),
    );
  }
}
