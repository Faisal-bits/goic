import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Ensure you've added intl to your pubspec.yaml
import 'home/gid_page.dart';
import '../models/search_config.dart';
import '../models/shared_history.dart';
import '../models/history_notifier.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<SearchConfig>> _searchHistoryFuture;

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
    setState(() {
      _searchHistoryFuture = loadSearchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

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

          // Group searches by date
          Map<String, List<SearchConfig>> groupedSearches = {};
          for (var search in snapshot.data!) {
            (groupedSearches[search.date] ??= []).add(search);
          }

          return ListView(
            children: groupedSearches.entries.map((entry) {
              String title = entry.key == today
                  ? "Today's Searches"
                  : "Searches on ${entry.key}";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title, style: TextStyle(color: Colors.grey)),
                  ),
                  Column(
                    children: entry.value.asMap().entries.map((indexedSearch) {
                      var searchConfig = indexedSearch.value;
                      int index = indexedSearch.key;
                      // Unique key for each Slidable
                      Key key = Key('$title-$index');
                      return Slidable(
                        key: key,
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  _deleteSearchConfig(searchConfig),
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: ListTile(
                            title: Text(
                              'Year: ${searchConfig.year}, ISIC: ${searchConfig.isic}, Status: ${searchConfig.status}',
                            ),
                            leading: Icon(Icons.history),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      GIDPage(initialConfig: searchConfig)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
