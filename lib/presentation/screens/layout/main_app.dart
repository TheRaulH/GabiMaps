import 'package:flutter/material.dart';
import 'package:gabimaps/presentation/screens/home/home_screen.dart';
import 'package:gabimaps/presentation/screens/map/map_screen.dart';
import 'package:gabimaps/presentation/screens/notifications/notifications_screen.dart';
import 'package:gabimaps/presentation/screens/settings/profile_screen.dart';
 

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MapScreen(), // Necesitas crear este widget
    NotificationsScreen(), // Necesitas crear este widget
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        
        destinations: const <Widget>[
          
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Perfil'),
        ],
      ),
    );
  }
}
