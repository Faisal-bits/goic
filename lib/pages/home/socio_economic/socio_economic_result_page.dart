import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:goic/services/api_service.dart';
import 'dart:math';
import 'package:goic/localization.dart';

class SocioEconomicResultPage extends StatefulWidget {
  final int countryId;
  final int? comparisonCountryId;
  final int economicIndicatorId;
  final bool comparisonMode;
  final String economicIndicatorName;

  const SocioEconomicResultPage({
    Key? key,
    required this.countryId,
    this.comparisonCountryId,
    required this.economicIndicatorId,
    required this.comparisonMode,
    required this.economicIndicatorName,
  }) : super(key: key);

  @override
  State<SocioEconomicResultPage> createState() =>
      _SocioEconomicResultPageState();
}

class _SocioEconomicResultPageState extends State<SocioEconomicResultPage> {
  List<dynamic> _economicData = [];
  List<dynamic> _comparisonEconomicData = [];
  Map<String, String> _countryIdToNameMap = {};
  String _countryArea = '';
  String _population = '';
  String _comparisonCountryArea = '';
  String _comparisonPopulation = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    ApiService apiService = ApiService();
    List<dynamic> countries = await apiService.fetchCountries();
    Map<String, String> countryIdToNameMap = {};
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;

    for (var country in countries) {
      countryIdToNameMap[country['countryid'].toString()] =
          localizations.locale.languageCode == 'ar'
              ? country['namearabic']
              : country['nameenglish'];
    }

    int currentYear = DateTime.now().year - 1;
    List<dynamic> economicData = [];
    List<dynamic> comparisonEconomicData = [];

    for (int year = currentYear - 4; year <= currentYear; year++) {
      List<dynamic> yearData = await apiService.fetchSOECData(
        year: year,
        countryId: widget.countryId,
      );

      List<dynamic> yearEconomicData = yearData
          .where((data) => data['soecid'] == widget.economicIndicatorId)
          .toList();

      economicData.addAll(yearEconomicData);

      if (widget.comparisonMode && widget.comparisonCountryId != null) {
        List<dynamic> comparisonYearData = await apiService.fetchSOECData(
          year: year,
          countryId: widget.comparisonCountryId!,
        );

        List<dynamic> comparisonYearEconomicData = comparisonYearData
            .where((data) => data['soecid'] == widget.economicIndicatorId)
            .toList();

        comparisonEconomicData.addAll(comparisonYearEconomicData);
      }
    }

    String countryArea = '';
    String population = '';
    String comparisonCountryArea = '';
    String comparisonPopulation = '';

    try {
      countryArea = (await apiService.fetchSOECData(
              year: currentYear, countryId: widget.countryId))
          .firstWhere((data) => data['soecid'] == 100,
              orElse: () => {'value': ''})['value'];

      population = (await apiService.fetchSOECData(
              year: currentYear, countryId: widget.countryId))
          .firstWhere((data) => data['soecid'] == 101,
              orElse: () => {'value': ''})['value'];

      if (population.isEmpty) {
        int previousYear = currentYear - 1;
        while (previousYear >= currentYear - 3 && population.isEmpty) {
          population = (await apiService.fetchSOECData(
                  year: previousYear, countryId: widget.countryId))
              .firstWhere((data) => data['soecid'] == 101,
                  orElse: () => {'value': ''})['value'];
          previousYear--;
        }
      }

      if (widget.comparisonMode && widget.comparisonCountryId != null) {
        comparisonCountryArea = (await apiService.fetchSOECData(
                year: currentYear, countryId: widget.comparisonCountryId!))
            .firstWhere((data) => data['soecid'] == 100,
                orElse: () => {'value': ''})['value'];

        comparisonPopulation = (await apiService.fetchSOECData(
                year: currentYear, countryId: widget.comparisonCountryId!))
            .firstWhere((data) => data['soecid'] == 101,
                orElse: () => {'value': ''})['value'];

        if (comparisonPopulation.isEmpty) {
          int previousYear = currentYear - 1;
          while (
              previousYear >= currentYear - 3 && comparisonPopulation.isEmpty) {
            comparisonPopulation = (await apiService.fetchSOECData(
                    year: previousYear, countryId: widget.comparisonCountryId!))
                .firstWhere((data) => data['soecid'] == 101,
                    orElse: () => {'value': ''})['value'];
            previousYear--;
          }
        }
      }

      print('Country Area: $countryArea');
      print('Population: $population');
      print('Comparison Country Area: $comparisonCountryArea');
      print('Comparison Population: $comparisonPopulation');
    } catch (e) {
      print('Error fetching country area or population: $e');
    }

    setState(() {
      _economicData = economicData;
      _comparisonEconomicData = comparisonEconomicData;
      _countryIdToNameMap = countryIdToNameMap;
      _countryArea = countryArea;
      _population = population;
      _comparisonCountryArea = comparisonCountryArea;
      _comparisonPopulation = comparisonPopulation;
    });
  }

  String formatPopulation(String population) {
    if (population.isEmpty) return '';

    double value = double.parse(population) * 1000;

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    String countryName = _countryIdToNameMap[widget.countryId.toString()] ?? '';
    String comparisonCountryName =
        _countryIdToNameMap[widget.comparisonCountryId?.toString() ?? ''] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('$countryName - ${localizations.socioEconomic}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.comparisonMode) ...[
              _buildInfoCard(
                  countryName, _countryArea, _population, localizations),
              _buildInfoCard(comparisonCountryName, _comparisonCountryArea,
                  _comparisonPopulation, localizations),
            ] else
              _buildInfoCard(
                  countryName, _countryArea, _population, localizations),
            const SizedBox(height: 16),
            _buildBarChart(
              title: widget.economicIndicatorName,
              data: _economicData,
              comparisonData: _comparisonEconomicData,
              comparisonMode: widget.comparisonMode,
              countryName: countryName,
              comparisonCountryName: comparisonCountryName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String countryName, String countryArea,
      String population, AppLocalizations localizations) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$countryName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.countryArea}: $countryArea km²',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.population}: ${formatPopulation(population)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart({
    required String title,
    required List<dynamic> data,
    required List<dynamic> comparisonData,
    required bool comparisonMode,
    required String countryName,
    required String comparisonCountryName,
  }) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: max(
                        data.fold<double>(
                            0,
                            (maxValue, data) =>
                                maxValue > double.parse(data['value'])
                                    ? maxValue
                                    : double.parse(data['value'])),
                        comparisonData.fold<double>(
                            0,
                            (maxValue, data) =>
                                maxValue > double.parse(data['value'])
                                    ? maxValue
                                    : double.parse(data['value']))) *
                    1.2,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final year = DateTime.now().year - 5 + value.toInt();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            year.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        double adjustedValue = value * 1000000;
                        String formattedValue;

                        if (adjustedValue >= 1000000000) {
                          formattedValue =
                              '${(adjustedValue / 1000000000).toStringAsFixed(1)}B';
                        } else if (adjustedValue >= 1000000) {
                          formattedValue =
                              '${(adjustedValue / 1000000).toStringAsFixed(1)}M';
                        } else if (adjustedValue >= 1000) {
                          formattedValue =
                              '${(adjustedValue / 1000).toStringAsFixed(1)}K';
                        } else {
                          formattedValue = adjustedValue.toStringAsFixed(1);
                        }

                        return Text(
                          formattedValue,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String tooltipValue;
                      double adjustedValue = rod.toY * 1000000;

                      if (adjustedValue >= 1000000000) {
                        tooltipValue =
                            '${(adjustedValue / 1000000000).toStringAsFixed(1)}B';
                      } else if (adjustedValue >= 1000000) {
                        tooltipValue =
                            '${(adjustedValue / 1000000).toStringAsFixed(1)}M';
                      } else if (adjustedValue >= 1000) {
                        tooltipValue =
                            '${(adjustedValue / 1000).toStringAsFixed(1)}K';
                      } else {
                        tooltipValue = adjustedValue.toStringAsFixed(1);
                      }

                      return BarTooltipItem(
                        tooltipValue,
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: comparisonMode
                    ? List.generate(data.length, (index) {
                        return BarChartGroupData(
                          x: data[index]['year'] - (DateTime.now().year - 5),
                          barRods: [
                            BarChartRodData(
                              toY: double.parse(data[index]['value']),
                              color: Colors.blue,
                            ),
                            if (index < comparisonData.length)
                              BarChartRodData(
                                toY: double.parse(
                                    comparisonData[index]['value']),
                                color: Colors.green,
                              ),
                          ],
                          barsSpace: 4,
                        );
                      })
                    : List.generate(data.length, (index) {
                        return BarChartGroupData(
                          x: data[index]['year'] - (DateTime.now().year - 5),
                          barRods: [
                            BarChartRodData(
                              toY: double.parse(data[index]['value']),
                              color: Colors.blue,
                            ),
                          ],
                        );
                      }),
              ),
            ),
          ),
          if (comparisonMode) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(countryName),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(comparisonCountryName),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
