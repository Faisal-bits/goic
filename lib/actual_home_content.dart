import 'package:flutter/material.dart';
import 'gid_page.dart'; // Ensure this page is properly implemented
import 'f_trade_page.dart'; // Ensure this page is properly implemented
import 'socio_economic_search_page.dart'; // Ensure this page is properly implemented

class SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onTap;

  const SectionContainer({
    Key? key,
    required this.title,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class ActualHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate the height for the "Trending" section and other sections based on screen size
    final trendingSectionHeight =
        100.0; // Fixed height for the "Trending" section
    final otherSectionsHeight = MediaQuery.of(context).size.height /
        10; // Increased height for the other sections

    return ListView(
      padding:
          const EdgeInsets.only(top: 40), // Added more padding from the top
      children: [
        SectionContainer(
          title: "Trending 🔥",
          onTap: () {}, // No action on tap for the container itself
          child: SizedBox(
            height: trendingSectionHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4, // Example item count for trending items
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    alignment: Alignment.center,
                    child: Text("Trending Item ${index + 1}"),
                  ),
                );
              },
            ),
          ),
        ),
        SectionContainer(
          title: "GID",
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => GIDPage())),
          child: SizedBox(
            height: otherSectionsHeight,
            child: Center(child: Text("GID Info Here")),
          ),
        ),
        SectionContainer(
          title: "F Trade",
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => FTradePage())),
          child: SizedBox(
            height: otherSectionsHeight,
            child: Center(child: Text("F Trade Info Here")),
          ),
        ),
        SectionContainer(
          title: "Socio Economic",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SocioEconomicSearchPage())),
          child: SizedBox(
            height: otherSectionsHeight,
            child: Center(child: Text("Socio Economic Info Here")),
          ),
        ),
      ],
    );
  }
}
