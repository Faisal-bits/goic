import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GIDPage extends StatefulWidget {
  @override
  _GIDPageState createState() => _GIDPageState();
}

class _GIDPageState extends State<GIDPage> {
  int selectedTimeFrame = 1; // Default to 1Y

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GID Summary"),
        actions: [
          // Toggle for 1Y, 2Y, 3Y
          PopupMenuButton<int>(
            onSelected: (int result) {
              setState(() {
                selectedTimeFrame = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text('1Y'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('2Y'),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text('3Y'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryWidget(),
            SizedBox(height: 20),
            _buildHorizontalBarCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryWidget() {
    // Placeholder for summary statistics
    // Replace with your actual data and logic for calculating changes
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Summary Statistics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard("No. of Firms", "100", "2.5%", true),
              _buildStatCard("Investment (USD MILL)", "50M", "-1.2%", false),
              _buildStatCard("No. of Labor", "10K", "0.8%", true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String percentage, bool isPositive) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(percentage,
            style: TextStyle(color: isPositive ? Colors.green : Colors.red)),
      ],
    );
  }

  Widget _buildHorizontalBarCharts() {
    // Placeholder for horizontal bar charts
    // You'll need to replace it with actual BarChart widgets with your data
    return Container(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: BarChart(BarChartData()), // Placeholder, use actual data
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: BarChart(BarChartData()), // Placeholder, use actual data
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: BarChart(BarChartData()), // Placeholder, use actual data
          ),
        ],
      ),
    );
  }
}
