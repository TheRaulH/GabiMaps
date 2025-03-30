// lib/presentation/screenstree/routes.dart
import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/auth/register_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/home/home_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/map/add_location_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/map/location_details_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/settings/profile_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/splash_screen.dart'; // Ruta de importación correcta

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addLocation = '/addLocation';
  static const String locationDetails = '/locationDetails';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    home: (context) => HomeScreen(),
    addLocation: (context) => AgregarUbicacionScreen(),
    locationDetails: (context) => LocationDetailsScreen(),
    profile: (context) => ProfileScreen(),
  };
}
