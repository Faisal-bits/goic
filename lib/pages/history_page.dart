import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'home/gid_page.dart';
import '/models/search_config.dart';
import '/models/shared_history.dart';
import '/models/history_notifier.dart';
import 'package:goic/localization.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<SearchConfig>> _searchHistoryFuture;

  String determineDatabaseType(SearchConfig config) {
    final localizations = AppLocalizations.of(context);
    if (config.isic?.isNotEmpty ?? false) {
      return localizations?.gid ?? "GID";
    } else if (config.country?.isNotEmpty ?? false) {
      return localizations?.socioEconomic ?? "Socio Economic";
    } else {
      return localizations?.fTrade ?? "F Trade";
    }
  }

  @override
  void initState() {
    super.initState();
    refreshHistory();
    HistoryNotifier().addListener(refreshHistory);
  }

  @override
  void dispose() {
    HistoryNotifier().removeListener(refreshHistory);
    super.dispose();
  }

  void refreshHistory() {
    setState(() {
      _searchHistoryFuture = loadSearchHistory();
    });
  }

  void _deleteSearchConfig(SearchConfig config) async {
    await deleteSearchFromHistory(config);
    refreshHistory();
  }

  Widget _buildHistoryItem(SearchConfig config, int index) {
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
          title: Text(
              'Year: ${config.year}, ISIC: ${config.isic}, Status: ${config.status}',
              style: const TextStyle(fontSize: 16)),
          subtitle: Text(databaseType,
              style: TextStyle(color: Theme.of(context).primaryColor)),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GIDPage(initialConfig: config))),
        ),
      ),
    );
  }

  Widget _buildGroupedSearches(List<SearchConfig> searchHistory) {
    final localizations = AppLocalizations.of(context);
    Map<String, List<SearchConfig>> groupedByDate = {};

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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.searchHistory ?? 'Search History'),
      ),
      body: FutureBuilder<List<SearchConfig>>(
        future: _searchHistoryFuture,
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
