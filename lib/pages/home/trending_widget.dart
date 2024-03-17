import 'package:flutter/material.dart';

class TrendingWidget extends StatelessWidget {
  TrendingWidget({super.key});

  final List<String> trendingItems = [
    "Item 1",
    "Item 2",
    "Item 3",
    "Item 4",
    "Item 5", // Example items for now
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // height for the container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trendingItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: SizedBox(
              width: 160, // fixed width for each card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.trending_up,
                      size: 50, color: Theme.of(context).primaryColor),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trendingItems[index],
                        style: const TextStyle(fontSize: 16)),
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
