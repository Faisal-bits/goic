import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gid_page.dart'; // Ensure this is the correct import path
import 'f_trade_page.dart'; // Ensure this is the correct import path
import 'socio_economic/socio_economic_search_page.dart'; // Ensure this is the correct import path

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

class ActualHomeContent extends StatefulWidget {
  @override
  _ActualHomeContentState createState() => _ActualHomeContentState();
}

class _ActualHomeContentState extends State<ActualHomeContent> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String firstName = userData['firstName'] ?? '';
      setState(() {
        _userName = firstName;
      });
    }
  }

  final List<Map<String, dynamic>> trendingData = [
    {
      'country': 'Qatar',
      'year': 2023,
      'type': 'Export',
      'change': '23% up from 2022'
    },
    {
      'country': 'Saudi',
      'year': 2022,
      'type': 'Import',
      'change': '15% down from 2021'
    },
    {
      'country': 'UAE',
      'year': 2021,
      'type': 'Re-Export',
      'change': '10% up from 2020'
    },
    {
      'country': 'Bahrain',
      'year': 2020,
      'type': 'Export',
      'change': '5% up from 2019'
    },
    // Add more items as needed
  ];

  final Map<String, Color> countryColors = {
    'Qatar': Color(0xFF8C1D40), // Maroon
    'Saudi': Color(0xFF006D2C), // Green
    'UAE': Colors.black, // Dark grey or black
    'Bahrain': Colors.redAccent, // Bright red
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(top: 40),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Welcome, $_userName",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 20), // Spacing after welcome message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Trending 🔥",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign:
                  TextAlign.left, // Aligns the Trending title to the left
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingData.length,
                    itemBuilder: (context, index) {
                      final item = trendingData[index];
                      final itemColor =
                          countryColors[item['country']] ?? Colors.grey;
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: itemColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Reduced padding inside each trending item
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${item['country']} ${item['year']} ${item['type']}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Text(
                                item['change'],
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
