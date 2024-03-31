import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gid_page.dart';
import 'f_trade_page.dart';
import 'socio_economic/socio_economic_search_page.dart';
import 'package:goic/localization.dart';

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
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
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
        width:
            MediaQuery.of(context).size.width * 0.4, // width, can be adjusted
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
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
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
  const ActualHomeContent({super.key});

  @override
  State<ActualHomeContent> createState() => _ActualHomeContentState();
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
  ];

  final Map<String, Color> countryColors = {
    'Qatar': const Color(0xFF8C1D40),
    'Saudi': const Color(0xFF006D2C),
    'UAE': Colors.black,
    'Bahrain': Colors.redAccent,
  };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    List<Widget> buildTrendingItems() {
      return trendingData.map((item) {
        final countryName = localizations.getCountryName(item['country']);
        final typeDescription =
            localizations.getTypeDescription(item['type'].toLowerCase());
        final changeDescription = localizations.translateChange(item['change']);

        final itemDescription =
            "$countryName ${item['year']} $typeDescription, $changeDescription";
        final itemColor = countryColors[item['country']] ?? Colors.grey;

        return GestureDetector(
          onTap: () {
            // Navigate to the FTradePage when the item is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FTradePage(
                  year: item['year'] as int,
                  tradeType: item['type'] as String,
                ),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                itemDescription,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(top: 40),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              localizations.welcome(_userName),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              localizations.trending,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
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
                  height: 150, // Adjust as needed for vertical space
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: buildTrendingItems(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SectionContainer(
            title: localizations.gid,
            subtitle: "",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GIDPage())),
            icon: Icons.pie_chart_outline,
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 5),
          SectionContainer(
            title: localizations.fTrade,
            subtitle: "",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FTradePage())),
            icon: Icons.import_export,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 5),
          SectionContainer(
            title: localizations.socioEconomic,
            subtitle: "",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SocioEconomicSearchPage())),
            icon: Icons.people_outline,
            color: Colors.purple.shade600,
          ),
        ],
      ),
    );
  }
}
