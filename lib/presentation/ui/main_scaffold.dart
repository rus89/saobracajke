import 'package:flutter/material.dart';
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
    const HomeScreen(), // Your new "Home"
    const MapScreen(), // The Flutter Map
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: _currentIndex == 0 ? 'Pregled tab content' : 'Mapa tab content',
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Semantics(
        label: 'Main navigation. Tab ${_currentIndex + 1} of 2 selected.',
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
          ],
        ),
      ),
    );
  }
}
