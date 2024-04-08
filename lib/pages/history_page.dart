import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'home/gid_page.dart';
import 'home/f_trade_page.dart';
import 'home/socio_economic/socio_economic_result_page.dart';
import '/models/search_config.dart';
import '/models/shared_history.dart';
import '/models/history_notifier.dart';
import 'package:goic/localization.dart';
import 'package:goic/services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<SearchConfig>> _searchHistoryFuture;
  late Future<List<FTradeSearchConfig>> _fTradeSearchHistoryFuture;
  late Future<List<SOESearchConfig>> _soeSearchHistoryFuture;
  Map<int, String> _countryIdToNameMap = {};
  Map<int, String> _economicIndicatorIdToNameMap = {};

  String determineDatabaseType(dynamic config) {
    final localizations = AppLocalizations.of(context);
    if (config is SearchConfig) {
      return localizations?.gid ?? "GID";
    } else if (config is FTradeSearchConfig) {
      return localizations?.fTrade ?? "F Trade";
    } else if (config is SOESearchConfig) {
      return "SOE";
    } else {
      return "Unknown";
    }
  }

  @override
  void initState() {
    super.initState();
    refreshHistory();
    HistoryNotifier().addListener(refreshHistory);
    _fetchCountryAndEconomicIndicatorMaps();
  }

  Future<void> _fetchCountryAndEconomicIndicatorMaps() async {
    ApiService apiService = ApiService();
    List<dynamic> countries = await apiService.fetchCountries();
    List<dynamic> economicIndicators = await apiService.fetchSOECIndicators();

    setState(() {
      _countryIdToNameMap = {
        for (var country in countries)
          country['countryid']: country['nameenglish']
      };
      _economicIndicatorIdToNameMap = {
        for (var indicator in economicIndicators)
          indicator['soecid']: indicator['nameenglish']
      };
    });
  }

  @override
  void dispose() {
    HistoryNotifier().removeListener(refreshHistory);
    super.dispose();
  }

  void refreshHistory() {
    setState(() {
      _searchHistoryFuture = loadSearchHistory();
      _fTradeSearchHistoryFuture = loadFTradeSearchHistory();
      _soeSearchHistoryFuture = loadSOESearchHistory();
    });
  }

  void _deleteSearchConfig(dynamic config) async {
    if (config is SearchConfig) {
      await deleteSearchFromHistory(config);
    } else if (config is FTradeSearchConfig) {
      await deleteFTradeSearchFromHistory(config);
    } else if (config is SOESearchConfig) {
      await deleteSOESearchFromHistory(config);
    }
  }

  Widget _buildHistoryItem(dynamic config, int index) {
    final localizations = AppLocalizations.of(context);
    String databaseType = determineDatabaseType(config);

    return Slidable(
      key: Key('history_item_$index'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => _deleteSearchConfig(config),
        ),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteSearchConfig(config),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: localizations?.delete ?? 'Delete',
            autoClose: false,
          ),
        ],
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: const Icon(Icons.history, size: 28),
          title: config is SearchConfig
              ? Text(
                  'Year: ${config.year}, ISIC: ${config.isic}, Status: ${config.status}',
                  style: const TextStyle(fontSize: 16),
                )
              : config is FTradeSearchConfig
                  ? Text(
                      'Year: ${config.year}, Trade Type: ${config.tradeType}',
                      style: const TextStyle(fontSize: 16),
                    )
                  : config is SOESearchConfig
                      ? Text(
                          'Country: ${_countryIdToNameMap[config.countryId] ?? 'Unknown'}, '
                          'Economic Indicator: ${_economicIndicatorIdToNameMap[config.economicIndicatorId] ?? 'Unknown'}, '
                          'Comparison Mode: ${config.comparisonMode ? "On" : "Off"}, '
                          'Comparison Country: ${config.comparisonMode ? (_countryIdToNameMap[config.comparisonCountryId] ?? 'Unknown') : 'N/A'}',
                          style: const TextStyle(fontSize: 16),
                        )
                      : const SizedBox(),
          subtitle: Text(
            databaseType,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onTap: () {
            if (config is SearchConfig) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GIDPage(initialConfig: config)),
              );
            } else if (config is FTradeSearchConfig) {
              int initialCategoryIndex;
              switch (config.tradeType) {
                case 'Imports':
                  initialCategoryIndex = 0;
                  break;
                case 'Exports':
                  initialCategoryIndex = 1;
                  break;
                case 'Re-exports':
                  initialCategoryIndex = 2;
                  break;
                default:
                  initialCategoryIndex = 0;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FTradePage(
                    year: config.year,
                    initialCategoryIndex: initialCategoryIndex,
                  ),
                ),
              );
            } else if (config is SOESearchConfig) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocioEconomicResultPage(
                    countryId: config.countryId,
                    comparisonCountryId: config.comparisonCountryId,
                    economicIndicatorId: config.economicIndicatorId,
                    comparisonMode: config.comparisonMode,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGroupedSearches(List<dynamic> searchHistory) {
    final localizations = AppLocalizations.of(context);
    Map<String, List<dynamic>> groupedByDate = {};

    for (var config in searchHistory) {
      String formattedDate =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(config.date));
      groupedByDate[formattedDate] = [
        ...(groupedByDate[formattedDate] ?? []),
        config
      ];
    }

    List<Widget> groupedWidgets = [];
    groupedByDate.forEach((date, configs) {
      String title;
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      if (DateFormat('yyyy-MM-dd').format(now) == date) {
        title = localizations?.todaysSearches ?? "Today's Searches";
      } else if (DateFormat('yyyy-MM-dd').format(yesterday) == date) {
        title = localizations?.yesterdaysSearches ?? "Yesterday's Searches";
      } else {
        title = "${localizations?.searchesOn ?? 'Searches on'} $date";
      }

      groupedWidgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 18)),
      ));

      for (var config in configs) {
        groupedWidgets.add(_buildHistoryItem(config, configs.indexOf(config)));
      }
    });

    return ListView(
      children: groupedWidgets,
    );
  }

  Future<void> clearAllSearchHistory() async {
    await saveSearchHistory([]);
    await saveFTradeSearchHistory([]);
    await saveSOESearchHistory([]);
    refreshHistory();
  }

  Future<void> deleteTodaysSearches() async {
    List<SearchConfig> searchHistory = await loadSearchHistory();
    List<FTradeSearchConfig> fTradeSearchHistory =
        await loadFTradeSearchHistory();
    List<SOESearchConfig> soeSearchHistory = await loadSOESearchHistory();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<SearchConfig> filteredSearchHistory = searchHistory
        .where((item) =>
            DateFormat('yyyy-MM-dd').format(DateTime.parse(item.date)) != today)
        .toList();
    List<FTradeSearchConfig> filteredFTradeSearchHistory = fTradeSearchHistory
        .where((item) =>
            DateFormat('yyyy-MM-dd').format(DateTime.parse(item.date)) != today)
        .toList();
    List<SOESearchConfig> filteredSOESearchHistory = soeSearchHistory
        .where((item) =>
            DateFormat('yyyy-MM-dd').format(DateTime.parse(item.date)) != today)
        .toList();
    await saveSearchHistory(filteredSearchHistory);
    await saveFTradeSearchHistory(filteredFTradeSearchHistory);
    await saveSOESearchHistory(filteredSOESearchHistory);
    refreshHistory();
  }

  void _deleteAllRecords() async {
    await clearAllSearchHistory();
    refreshHistory();
  }

  void _deleteTodaysRecords() async {
    await deleteTodaysSearches();
    refreshHistory();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.searchHistory ?? 'Search History'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _deleteAllRecords(),
            tooltip: localizations?.deleteAll ?? 'Delete All',
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _deleteTodaysRecords(),
            tooltip: localizations?.deleteTodays ?? 'Delete Today\'s',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _searchHistoryFuture,
          _fTradeSearchHistoryFuture,
          _soeSearchHistoryFuture,
        ]).then((results) => [...results[0], ...results[1], ...results[2]]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    localizations?.noRecentSearches ?? 'No recent searches'));
          }

          return _buildGroupedSearches(snapshot.data!);
        },
      ),
    );
  }
}
