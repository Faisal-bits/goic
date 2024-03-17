import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../models/search_config.dart';
import '../../models/shared_history.dart';
import 'package:intl/intl.dart';
import '../../models/history_notifier.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('GIDPage');

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

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialConfig?.year ?? DateTime.now().year;
    selectedISICSector = widget.initialConfig?.isic ?? '10'; // default
    selectedStatus = widget.initialConfig?.status ?? 'All'; // default
    filterData();
  }

  List<DropdownMenuItem<String>> getISICSectorItems() {
    List<Map<String, String>> isicSectors = [
      {'code': '10', 'description': 'Manufacture of food products'},
      // other sectors here...
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
  }

  void filterData() {
    final baseData = {
      'Saudi Arabia': [1200, 500, 300000],
      'UAE': [900, 450, 250000],
      'Qatar': [700, 300, 150000],
      'Kuwait': [500, 200, 120000],
      'Oman': [400, 150, 100000],
      'Bahrain': [300, 100, 80000],
    };

    // Simulate fetching data based on filters. This right now only considers the year.
    countryDataList = List.generate(6, (index) {
      String country = baseData.keys.elementAt(index);
      List<int> values = baseData[country]!;
      // multiplier or formula for simulation
      double yearMultiplier = (selectedYear - 2020).toDouble();
      return CountryData(
        name: country,
        noOfFirms: values[0] + 100.0 * yearMultiplier,
        investment: values[1] + 50.0 * yearMultiplier,
        noOfLabor: values[2] + 30000.0 * yearMultiplier,
      );
    });
    setState(() {});
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
    List<int> years = List.generate(6, (index) => DateTime.now().year - index);
    return DropdownButtonFormField<int>(
      isExpanded: true,
      value: selectedYear,
      decoration: const InputDecoration(labelText: 'Year'),
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
      // other sectors here ...
      {
        'code': '33',
        'description': 'Repair and installation of machinery and equipment'
      },
    ];

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedISICSector,
      decoration: const InputDecoration(labelText: 'ISIC Sector'),
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
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(formattedValue,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(percentage,
                style:
                    TextStyle(color: isPositive ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000 && value < 1000000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    return value.toStringAsFixed(0);
  }

  String formatPercentage(double value, double total) {
    if (total == 0) return "N/A"; // Prevent division by zero
    double percentage = value / total * 100;
    return "${percentage.toStringAsFixed(1)}%";
  }

  Widget _buildGCCSummaryCard() {
    final totalFirms =
        countryDataList.fold<double>(0, (sum, item) => sum + item.noOfFirms);
    final totalInvestment =
        countryDataList.fold<double>(0, (sum, item) => sum + item.investment);
    final totalLabor =
        countryDataList.fold<double>(0, (sum, item) => sum + item.noOfLabor);

    // No need to convert to Int and then to String, directly pass double to _buildStatCard
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
                child: _buildStatCard("Investment (USD MILL)", totalInvestment,
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

  String formatAxisValue(double value) {
    if (value >= 1000 && value < 10000) {
      // For values between 1K and 9.999K, include one decimal point
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value >= 10000 && value < 1000000) {
      // For values 10K and above, show without decimal points until it reaches a million
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else if (value >= 1000000) {
      // For values in millions, show with one decimal point for precision
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
                    tooltipPadding: const EdgeInsets.all(4), // tooltip padding
                    tooltipMargin: 8, // Adjust tooltip margin
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatAxisValue(rod.toY) +
                            (rod.toY >= 1000 ? '' : ''), // tooltip text
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 12), // tooltip font size
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, _) {
                        return Text(countryDataList[value.toInt()].name,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, _) => Text(
                          formatAxisValue(value),
                          style: const TextStyle(
                              color: Color(0xff7589a2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      reservedSize: 40, // y-axis label spacing
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
