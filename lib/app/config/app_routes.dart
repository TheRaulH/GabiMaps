// lib/app/config/routes.dart
import 'package:flutter/material.dart';
import 'package:gabimaps/features/auth/ui/login_screen.dart';
import 'package:gabimaps/features/auth/ui/reset_password_screen.dart';
import 'package:gabimaps/features/home/ui/red_social.dart';
import 'package:gabimaps/features/home/ui/saved.dart';
import 'package:gabimaps/features/user/ui/profile_screen.dart';
import 'package:gabimaps/layout/main_app.dart';
import 'package:gabimaps/features/map/ui/map_screen.dart';
import 'package:gabimaps/features/notifications/ui/notifications_screen.dart';
import 'package:gabimaps/features/map/ui/locations_management_page.dart';
import 'package:gabimaps/features/user/ui/user_management_page.dart'; 
import '../../features/auth/ui/register_screen.dart';
import '../../features/map/ui/location_details_screen.dart';
import '../../layout/splash_screen.dart';
import '../../features/user/ui/settings_page.dart';  


class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String locationDetails = '/locationDetails';
  static const String profile = '/profile';
  static const String map = '/map'; 
  static const String notifications =
      '/notifications';
  static const String mainapp = '/MainApp';
  static const String settings = '/settings';  
  static const String location =
      '/admin/locations'; 
  static const String users =
      '/admin/users'; 

  static const String redsocial =
      '/redsocial'; 

  static const String saved =
      '/saved';

  static const String resetPassword = '/resetPassword';


  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(), 
    locationDetails: (context) => LocationDetailsScreen(),
    profile: (context) => ProfileScreen(),
    map: (context) => MapScreen(), 
    notifications:
        (context) =>
            NotificationsScreen(), 
    mainapp:
        (context) => MainApp(),

    settings:
        (context) =>
            SettingsPage(),

    location:
        (context) =>
            LocationsManagementPage(),
    users:
        (context) =>
            UserManagementPage(),

    redsocial:
        (context) =>
            UAGRMRedSocialApp(),

    saved:
        (context) =>
            GuardadosPage(),

    resetPassword: (context) => ResetPasswordScreen(), 
  };
}
