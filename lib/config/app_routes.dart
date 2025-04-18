// lib/presentation/screenstree/routes.dart
import 'package:flutter/material.dart';
import 'package:gabimaps/presentation/screens/home/red_social.dart';
import 'package:gabimaps/presentation/screens/home/saved.dart';
import 'package:gabimaps/presentation/screens/layout/main_app.dart';
import 'package:gabimaps/presentation/screens/map/map_screen.dart';
import 'package:gabimaps/presentation/screens/notifications/notifications_screen.dart';
import 'package:gabimaps/presentation/screens/settings/locations_management_page.dart';
import 'package:gabimaps/presentation/screens/settings/user_management_page.dart';
import '../presentation/screens/auth/login_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/auth/register_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/home/home_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/map/location_details_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/settings/profile_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/splash_screen.dart'; // Ruta de importación correcta
import '../presentation/screens/settings/settings_page.dart'; // Ruta de importación correcta

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String locationDetails = '/locationDetails';
  static const String profile = '/profile';
  static const String map = '/map'; // Ruta para el mapa
  static const String notifications =
      '/notifications'; // Ruta para las notificaciones
  static const String mainapp = '/MainApp'; // Ruta para la pantalla de error
  static const String settings = '/settings'; // Ruta para la configuración
  static const String location =
      '/admin/locations'; // Ruta para el perfil de usuario
  static const String users =
      '/admin/users'; // Ruta para la gestión de usuarios (si es necesario)

  static const String redsocial =
      '/redsocial'; // Ruta para la red social (si es necesario)

  static const String saved =
      '/saved'; // Ruta para la pantalla de guardados (si es necesario)


  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    home: (context) => HomeScreen(),
    locationDetails: (context) => LocationDetailsScreen(),
    profile: (context) => UserProfilePage(),
    map: (context) => MapScreen(), // Asegúrate de que este widget esté definido
    notifications:
        (context) =>
            NotificationsScreen(), // Asegúrate de que este widget esté definido
    mainapp:
        (context) => MainApp(), // Asegúrate de que este widget esté definido

    settings:
        (context) =>
            SettingsPage(), // Asegúrate de que este widget esté definido

    location:
        (context) =>
            LocationsManagementPage(), // Asegúrate de que este widget esté definido
    users:
        (context) =>
            UserManagementPage(), // Asegúrate de que este widget esté definido

    redsocial:
        (context) =>
            UAGRMRedSocialApp(), // Asegúrate de que este widget esté definido

    saved:
        (context) =>
            GuardadosPage(), // Asegúrate de que este widget esté definido
  };
}
