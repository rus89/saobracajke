import 'package:flutter/material.dart';
import 'package:saobracajke/presentation/ui/screens/home_screen.dart';
import 'package:saobracajke/presentation/ui/screens/map_screen.dart';

//-------------------------------------------------------------------------------
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  static const _screens = <Widget>[
    HomeScreen(),
    MapScreen(),
  ];

  static const _labels = ['Pregled', 'Mapa'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentIndex = index);
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: '${_labels[_currentIndex]} tab content',
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Semantics(
        label: 'Main navigation. Tab ${_currentIndex + 1} of 2 selected.',
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Pregled',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
          ],
        ),
      ),
    );
  }
}
