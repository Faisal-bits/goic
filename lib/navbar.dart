import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Import your CommunityPage
import 'pages/community_page.dart';
// Continue with other imports
import 'pages/help_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/home/actual_home_content.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  Key _historyPageKey = UniqueKey();

  Widget _getWidgetOption(int index) {
    switch (index) {
      case 0:
        return ActualHomeContent();
      case 1:
        return CommunityPage(); // Community Page is now right after Home
      case 2:
        return HelpPage();
      case 3:
        return HistoryPage(key: _historyPageKey);
      case 4:
        return ProfilePage(); // Profile Page is now at the very right
      default:
        return ActualHomeContent();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List<Widget>.generate(5, (index) => _getWidgetOption(index)),
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community'), // Community icon next to Home
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.question_circle), label: 'Help'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Profile'), // Profile icon at the very right
        ],
        currentIndex: _selectedIndex,
        activeColor: Colors.blue.shade600,
        inactiveColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
