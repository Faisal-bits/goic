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
  Key _historyPageKey = UniqueKey(); // Add this line

  void refreshHistory() {
    setState(() {
      _historyPageKey =
          UniqueKey(); // This generates a new key, forcing the widget to rebuild
    });
  }

  // Updated to use a method to get the widget based on the selected index
  Widget _getWidgetOption(int index) {
    switch (index) {
      case 0:
        return ActualHomeContent();
      case 1:
        return HelpPage();
      case 2:
        return HistoryPage(
            key: _historyPageKey); // Now dynamically returning a new instance
      case 3:
        return ProfilePage();
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
        // Use a method to generate the current widget based on the selected index
        children: List<Widget>.generate(4, (index) => _getWidgetOption(index)),
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
        activeColor: Colors.blue.shade600,
        inactiveColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
