import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class CountryData {
  final String name;
  final double noOfFirms;
  final double investment;
  final double noOfLabor;

  CountryData({
    required this.name,
    required this.noOfFirms,
    required this.investment,
    required this.noOfLabor,
  });
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
  @override
  _GIDPageState createState() => _GIDPageState();
}

class _GIDPageState extends State<GIDPage> {
  int selectedYear = DateTime.now().year;
  String selectedISICSector = '10';
  String selectedStatus = 'All';

  List<DropdownMenuItem<String>> getISICSectorItems() {
    List<Map<String, String>> isicSectors = [
      {'code': '10', 'description': 'Manufacture of food products'},
      // Add other sectors here...
      {
        'code': '33',
        'description': 'Repair and installation of machinery and equipment'
      },
    ];
    return isicSectors
        .map((sector) => DropdownMenuItem<String>(
              value: sector['code']!,
              child: Text('${sector['code']}: ${sector['description']}'),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GID Summary"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Search Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFilters(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "GCC - Summary Stats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGCCSummaryCard(),
            SizedBox(height: 20),
            _buildHorizontalBarCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildYearDropdown()),
              SizedBox(width: 8),
              Expanded(child: _buildISICDropdown()),
              SizedBox(width: 8),
              Expanded(child: _buildStatusDropdown()),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print(
                  'Searching with filters: $selectedYear, $selectedISICSector, $selectedStatus');
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdown() {
    List<int> years = List.generate(6, (index) => DateTime.now().year - index);
    return DropdownButtonFormField<int>(
      isExpanded: true,
      value: selectedYear,
      decoration: InputDecoration(labelText: 'Year'),
      onChanged: (value) {
        setState(() {
          selectedYear = value!;
        });
      },
      items: years.map<DropdownMenuItem<int>>((int year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildISICDropdown() {
    List<Map<String, dynamic>> isicSectors = [
      {'code': '10', 'description': 'Manufacture of food products'},
      // Add other sectors according to your needs
      {
        'code': '33',
        'description': 'Repair and installation of machinery and equipment'
      },
    ];

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedISICSector,
      decoration: InputDecoration(labelText: 'ISIC Sector'),
      onChanged: (value) {
        setState(() {
          selectedISICSector = value!;
        });
      },
      items: isicSectors.map((sector) {
        return DropdownMenuItem<String>(
          value: sector['code'],
          child: Text('${sector['code']}: ${sector['description']}'),
        );
      }).toList(),
    );
  }

  Widget _buildStatusDropdown() {
    List<String> statuses = ['All', 'Licensed', 'Operational'];
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedStatus,
      decoration: InputDecoration(labelText: 'Status'),
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

  Widget _buildGCCSummaryCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: _buildStatCard("No. of Firms", "100", "2.5%", true)),
            Expanded(
                child: _buildStatCard(
                    "Investment (USD MILL)", "50M", "-1.2%", false)),
            Expanded(
                child: _buildStatCard("No. of Labor", "10K", "0.8%", true)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String percentage, bool isPositive) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(percentage,
                style:
                    TextStyle(color: isPositive ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBarCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Add this line
      children: [
        Padding(
          // Wrap the Text widget with Padding for better spacing
          padding: const EdgeInsets.symmetric(
              horizontal: 20), // Adjust padding as needed
          child: Text(
            "GCC - Bar Graphs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left, // Align text to the left
          ),
        ),
        SizedBox(height: 20),
        Container(
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

  String formatAxisValue(double value) {
    if (value >= 1000 && value < 1000000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildBarChart({
    required String title,
    required double Function(CountryData) dataSelector,
    required Color barColor,
  }) {
    final maxY = countryDataList.map(dataSelector).reduce(max) * 1.15;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barGroups: countryDataList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final country = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dataSelector(country),
                        color: barColor,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }).toList(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    tooltipPadding: EdgeInsets.all(4), // Smaller padding
                    tooltipMargin: 8, // Closer to the rod
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatAxisValue(rod.toY) +
                            (rod.toY >= 1000 ? '' : ''), // Format tooltip text
                        TextStyle(
                          color: Colors.white,
                          fontSize: 12, // Smaller font size
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, _) {
                        return Text(
                          countryDataList[value.toInt()].name,
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, _) => Text(
                        formatAxisValue(value), // Use the format function
                        style: TextStyle(
                          color: Color(0xff7589a2),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      reservedSize: 40,
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
