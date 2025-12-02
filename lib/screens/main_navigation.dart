import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // ❗ REMOVED const — FIXES THE ERROR
  final List<Widget> _pages = [
    HomeScreen(),
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },

        indicatorColor: const Color(0xFF6C4BFF).withOpacity(0.2),

        destinations: const [
          NavigationDestination(
            icon: Text("🏠", style: TextStyle(fontSize: 22)),
            selectedIcon: Text("🏠", style: TextStyle(fontSize: 26)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Text("🗓️", style: TextStyle(fontSize: 22)),
            selectedIcon: Text("🗓️", style: TextStyle(fontSize: 26)),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Text("⚙️", style: TextStyle(fontSize: 22)),
            selectedIcon: Text("⚙️", style: TextStyle(fontSize: 26)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
