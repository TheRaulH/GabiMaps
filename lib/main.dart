import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/presentation/screens/notifications/error_screen.dart';
import 'services/firebase_service.dart';
import 'config/app_routes.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  runApp(const ProviderScope(child: MyApp())); // 🔥 Riverpod envuelve la app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        if (AppRoutes.routes.containsKey(settings.name)) {
          return MaterialPageRoute(builder: AppRoutes.routes[settings.name]!);
        } else {
          return MaterialPageRoute(builder: (context) => ErrorScreen());
        }
      },

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          ThemeMode
              .system, // Cambia entre light y dark según la configuración del sistema
    );
  }
}
