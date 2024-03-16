import 'package:flutter/material.dart';

class TrendingWidget extends StatelessWidget {
  final List<String> trendingItems = [
    "Item 1",
    "Item 2",
    "Item 3",
    "Item 4",
    "Item 5", // Example items, replace with actual data
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, // Set a height for the container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trendingItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Container(
              width: 160, // Set a fixed width for each card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Replace these widgets with whatever content you'd like to display for each trending item
                  Icon(Icons.trending_up,
                      size: 50, color: Theme.of(context).primaryColor),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trendingItems[index],
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
