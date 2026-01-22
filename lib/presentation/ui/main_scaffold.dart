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
      body: IndexedStack(
        // Keeps state alive when switching tabs
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Pregled",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Mapa",
          ),
        ],
      ),
    );
  }
}
