import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/community_page.dart';
import 'pages/help_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/home/actual_home_content.dart';
import 'localization.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  final Key _historyPageKey = UniqueKey();

  Widget _getWidgetOption(int index) {
    switch (index) {
      case 0:
        return const ActualHomeContent();
      case 1:
        return const CommunityPage();
      case 2:
        return const HelpPage();
      case 3:
        return HistoryPage(key: _historyPageKey);
      case 4:
        return ProfilePage();
      default:
        return const ActualHomeContent();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the localized strings
    final localization = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List<Widget>.generate(5, (index) => _getWidgetOption(index)),
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.home),
              label: localization?.home ?? 'Home'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: localization?.community ?? 'Community'),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.question_circle),
              label: localization?.help ?? 'Help'),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.clock),
              label: localization?.history ?? 'History'),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person),
              label: localization?.profile ?? 'Profile'),
        ],
        currentIndex: _selectedIndex,
        activeColor: Colors.blue.shade600,
        inactiveColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
