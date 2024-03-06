import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<String> searchHistory = [
    "Most recent search",
    "Search 1",
    "Search 2",
    "Search 3",
    // Add more search history items
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search History'),
      ),
      body: searchHistory.isEmpty
          ? Center(child: Text('No recent searches'))
          : ListView.builder(
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchHistory[index]),
                  leading: Icon(Icons.history),
                );
              },
            ),
    );
  }
}
