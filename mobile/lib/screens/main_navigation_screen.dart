import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'report_screen.dart';
import 'navigation_map_screen.dart';
import 'profile_screen.dart';
import '../services/inactivity_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final InactivityService _inactivityService = InactivityService();

  final List<Widget> _screens = [
    const HomeScreen(),
    const NavigationMapScreen(), // Replaced AlertsScreen with NavigationMapScreen
    const ReportScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Start monitoring safety once the user enters the main app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inactivityService.startMonitoring(context);
    });
  }

  void _onItemTapped(int index) {
    _inactivityService.userActivityDetected(context); // Reset timer on navigation
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _inactivityService.userActivityDetected(context), // Reset timer on any screen tap
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Navigate'), // Updated icon and label
            BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Report'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
