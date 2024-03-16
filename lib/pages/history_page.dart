import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Ensure you've added intl to your pubspec.yaml
import 'home/gid_page.dart';
import '/models/search_config.dart';
import '/models/shared_history.dart';
import '/models/history_notifier.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<SearchConfig>> _searchHistoryFuture;

  String determineDatabaseType(SearchConfig config) {
    if (config.isic?.isNotEmpty ?? false) {
      return "GID";
    } else if (config.country?.isNotEmpty ?? false) {
      return "Socio Economic";
    } else {
      return "F Trade";
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
    // Determine the database type based on the config's properties
    String databaseType = determineDatabaseType(config);

    return Slidable(
      key: Key('history_item_$index'),
      endActionPane: ActionPane(
        motion: DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteSearchConfig(config),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: 'Delete',
            autoClose: false,
          ),
        ],
        dismissible: DismissiblePane(
          onDismissed: () => _deleteSearchConfig(config),
        ),
      ),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: Icon(Icons.history, size: 28),
          title: Text(
              'Year: ${config.year}, ISIC: ${config.isic}, Status: ${config.status}',
              style: TextStyle(fontSize: 16)),
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
      DateTime yesterday = now.subtract(Duration(days: 1));
      if (DateFormat('yyyy-MM-dd').format(now) == date) {
        title = "Today's Searches";
      } else if (DateFormat('yyyy-MM-dd').format(yesterday) == date) {
        title = "Yesterday's Searches";
      } else {
        title = "Searches on $date";
      }

      groupedWidgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(title, style: TextStyle(color: Colors.grey, fontSize: 18)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Search History'),
      ),
      body: FutureBuilder<List<SearchConfig>>(
        future: _searchHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recent searches'));
          }

          return _buildGroupedSearches(snapshot.data!);
        },
      ),
    );
  }
}
