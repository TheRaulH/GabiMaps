import 'package:flutter/material.dart';
import 'package:gabimaps/presentation/screens/home/red_social.dart';
import 'package:gabimaps/presentation/screens/home/saved.dart';
import 'package:gabimaps/presentation/screens/map/map_screen.dart';
 

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MapScreen(), // Necesitas crear este widget
    GuardadosPage(),
    RedSocialUAGRM(), // Necesitas crear este widget 
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
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            label: 'Mapa',
          ),

          NavigationDestination(icon: Icon(Icons.label), label: 'Guardados'),
          
          NavigationDestination(
            icon: Icon(Icons.people_sharp),
            label: 'Red Social',
          ), 
        ],
      ),
    );
  }
}
