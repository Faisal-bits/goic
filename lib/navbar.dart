import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/community_page.dart';
import 'pages/help_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/home/actual_home_content.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List<Widget>.generate(5, (index) => _getWidgetOption(index)),
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.question_circle), label: 'Help'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        activeColor: Colors.blue.shade600,
        inactiveColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
