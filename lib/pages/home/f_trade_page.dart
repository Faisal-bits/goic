import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FTradePage extends StatefulWidget {
  @override
  _FTradePageState createState() => _FTradePageState();
}

class _FTradePageState extends State<FTradePage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('F Trade'),
      ),
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        children: <Widget>[
          TradeCategoryPage(category: 'Imports', pageIndex: 0),
          TradeCategoryPage(category: 'Exports', pageIndex: 1),
          TradeCategoryPage(category: 'Re-exports', pageIndex: 2),
        ],
      ),
    );
  }
}

class TradeCategoryPage extends StatelessWidget {
  final String category;
  final int pageIndex;

  const TradeCategoryPage(
      {Key? key, required this.category, required this.pageIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              category,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(height: 200, child: _buildPieChart()),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(height: 200, child: _buildLineChart()),
          ),
          SizedBox(height: 200, child: _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        pieTouchData:
            PieTouchData(touchCallback: (pieTouchResponse, touchInput) {
          // Your touch callback code here
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(6, (i) {
          return PieChartSectionData(
            color: Colors.blue[100 * (i + 1)],
            value: 25,
            title: 'Country ${i + 1}',
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        }),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 10),
              FlSpot(3, 7),
              FlSpot(4, 12),
              FlSpot(5, 10),
            ],
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 4,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(5, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (i + 1) * 5.0,
                color: Colors.pinkAccent,
              ),
            ],
          );
        }),
      ),
    );
  }
}
