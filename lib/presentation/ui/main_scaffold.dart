// ABOUTME: Root scaffold with bottom navigation bar switching between dashboard, map, and about tabs.
// ABOUTME: Uses IndexedStack to preserve tab state across navigation.
import 'package:flutter/material.dart';
import 'package:saobracajke/presentation/ui/screens/about_screen.dart';
import 'package:saobracajke/presentation/ui/screens/home_screen.dart';
import 'package:saobracajke/presentation/ui/screens/map_screen.dart';

//-------------------------------------------------------------------------------
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // The Screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: switch (_currentIndex) {
          0 => 'Pregled tab content',
          1 => 'Mapa tab content',
          2 => 'O aplikaciji tab content',
          _ => '',
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Semantics(
        label: 'Main navigation. Tab ${_currentIndex + 1} of 3 selected.',
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Pregled',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'O aplikaciji',
            ),
          ],
        ),
      ),
    );
  }
}
