import 'package:flutter/material.dart';
import 'package:goic/services/api_service.dart';
import 'socio_economic_result_page.dart';
import 'package:goic/models/search_config.dart';
import 'package:goic/models/shared_history.dart';
import 'package:intl/intl.dart';
import 'package:goic/models//history_notifier.dart';
import 'package:goic/localization.dart';

class SocioEconomicSearchPage extends StatefulWidget {
  const SocioEconomicSearchPage({super.key});

  @override
  State<SocioEconomicSearchPage> createState() =>
      _SocioEconomicSearchPageState();
}

class _SocioEconomicSearchPageState extends State<SocioEconomicSearchPage> {
  int selectedCountryId = 0;
  int? selectedComparisonCountryId;
  HistoryNotifier historyNotifier = HistoryNotifier();
  List<dynamic> _countries = [];
  List<dynamic> _economicIndicators = [];
  int selectedEconomicIndicatorId = 0;
  bool comparisonModeEnabled = false;

  @override
  void initState() {
    super.initState();
    ApiService apiService = ApiService();
    apiService.fetchCountries().then((countries) {
      setState(() {
        _countries = countries
            .where((country) => country['countryid'] != 10096) // GCC
            .toList();
        selectedCountryId =
            _countries.isNotEmpty ? _countries.first['countryid'] : 0;
      });
    });
    apiService.fetchSOECIndicators().then((indicators) {
      setState(() {
        _economicIndicators =
            indicators.where((i) => i['categoryid'] == 1).toList();
        selectedEconomicIndicatorId = _economicIndicators.isNotEmpty
            ? _economicIndicators.first['soecid']
            : 0;
      });
    });
  }

  void _onSearchPressed() async {
    final newSearchConfig = SOESearchConfig(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      countryId: selectedCountryId,
      comparisonCountryId: selectedComparisonCountryId,
      economicIndicatorId: selectedEconomicIndicatorId,
      comparisonMode: comparisonModeEnabled,
    );

    List<SOESearchConfig> currentHistory = await loadSOESearchHistory();
    currentHistory.add(newSearchConfig);
    await saveSOESearchHistory(currentHistory);

    historyNotifier.notifyListeners();

    String selectedEconomicIndicatorName = _economicIndicators.firstWhere(
        (indicator) =>
            indicator['soecid'] == selectedEconomicIndicatorId)['nameenglish'];

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocioEconomicResultPage(
          countryId: selectedCountryId,
          comparisonCountryId: selectedComparisonCountryId,
          economicIndicatorId: selectedEconomicIndicatorId,
          economicIndicatorName: selectedEconomicIndicatorName,
          comparisonMode: comparisonModeEnabled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.socioEconomic),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 1,
            color: Colors.grey[100],
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedCountryId,
                    decoration:
                        InputDecoration(labelText: localizations.country),
                    onChanged: (value) {
                      setState(() {
                        selectedCountryId = value!;
                      });
                    },
                    items: _countries.map<DropdownMenuItem<int>>((country) {
                      return DropdownMenuItem<int>(
                        value: country['countryid'],
                        child: Text(country[
                            localizations.locale.languageCode == 'en'
                                ? 'nameenglish'
                                : 'namearabic']),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedEconomicIndicatorId,
                    decoration: InputDecoration(
                        labelText: localizations.economicIndicator),
                    onChanged: (value) {
                      setState(() {
                        selectedEconomicIndicatorId = value!;
                      });
                    },
                    items: _economicIndicators
                        .map<DropdownMenuItem<int>>((indicator) {
                      return DropdownMenuItem<int>(
                        value: indicator['soecid'],
                        child: Text(indicator[
                            localizations.locale.languageCode == 'en'
                                ? 'nameenglish'
                                : 'namearabic']),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(localizations.comparisonMode),
                    value: comparisonModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        comparisonModeEnabled = value;
                      });
                    },
                  ),
                  if (comparisonModeEnabled) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedComparisonCountryId,
                      decoration: InputDecoration(
                          labelText: localizations.comparisonCountry),
                      onChanged: (value) {
                        setState(() {
                          selectedComparisonCountryId = value!;
                        });
                      },
                      items: _countries.map<DropdownMenuItem<int>>((country) {
                        return DropdownMenuItem<int>(
                          value: country['countryid'],
                          child: Text(country[
                              localizations.locale.languageCode == 'en'
                                  ? 'nameenglish'
                                  : 'namearabic']),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onSearchPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(localizations.search),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
