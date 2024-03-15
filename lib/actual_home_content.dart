import 'package:flutter/material.dart';
import 'gid_page.dart'; // Ensure this is the correct import path
import 'f_trade_page.dart'; // Ensure this is the correct import path
import 'socio_economic_search_page.dart'; // Ensure this is the correct import path

class SectionContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const SectionContainer({
    Key? key,
    required this.title,
    this.subtitle = "",
    required this.onTap,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            if (subtitle.isNotEmpty) ...[
              SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TrendingItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const TrendingItem({
    Key? key,
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.4, // Example width, adjust as needed
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ActualHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GCC Industrial Insights"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      "Trending 🔥",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 120, // Adjust height based on your content
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4, // Adjust this count as needed
                      itemBuilder: (context, index) {
                        // Example icons and colors, customize these as needed
                        IconData icon;
                        Color color;
                        switch (index) {
                          case 0:
                            icon = Icons.trending_up;
                            color = Colors.blue;
                            break;
                          case 1:
                            icon = Icons.new_releases;
                            color = Colors.red;
                            break;
                          case 2:
                            icon = Icons.star;
                            color = Colors.amber;
                            break;
                          case 3:
                          default:
                            icon = Icons.auto_awesome;
                            color = Colors.green;
                            break;
                        }

                        return TrendingItem(
                          title: "Trending ${index + 1}",
                          onTap: () {
                            print("Tapped on Trending ${index + 1}");
                            // Add navigation or other action here
                          },
                          icon: icon,
                          color: color,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5), // Additional spacing between sections
          SectionContainer(
            title: "GID",
            subtitle: "GCC Industrial Data",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => GIDPage())),
            icon: Icons.pie_chart_outline,
            color: Colors.blue.shade600,
          ),
          SizedBox(height: 5),
          SectionContainer(
            title: "F Trade",
            subtitle: "Foreign Trade Statistics",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => FTradePage())),
            icon: Icons.import_export,
            color: Colors.green.shade600,
          ),
          SizedBox(height: 5),
          SectionContainer(
            title: "Socio Economic",
            subtitle: "Socioeconomic Insights",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SocioEconomicSearchPage())),
            icon: Icons.people_outline,
            color: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }
}
