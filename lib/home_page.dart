import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Make sure these imports point to the correct files
import 'help_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'actual_home_content.dart'; // This should be the widget you want to show as the home content

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    ActualHomeContent(),
    HelpPage(),
    HistoryPage(),
    ProfilePage(),
  ];

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
        children: _widgetOptions,
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.question_circle), label: 'Help'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        activeColor: Colors.blue.shade600, // Set active color to navy blue
        inactiveColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
