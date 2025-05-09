import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/notifications/ui/error_screen.dart';
import 'shared/services/firebase_service.dart';
import 'app/config/app_routes.dart';
import 'app/config/theme.dart';
import 'app/core/theme_util.dart';

// Proveedor para el modo de tema
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Notificador de estado para gestionar el tema
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  // Método para cambiar el tema
  void changeTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  runApp(const ProviderScope(child: MyApp())); // 🔥 Riverpod envuelve la app
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtiene el modo de tema actual
    final themeMode = ref.watch(themeProvider);

    // Prepara los temas
    TextTheme textTheme = createTextTheme(context, "Poppins", "Montserrat");
    MaterialTheme theme = MaterialTheme(textTheme);

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

      // Configuración del tema
      themeMode: themeMode, // Usa el themeMode de Riverpod
      theme: theme.lightMediumContrast(), // Tema claro
      darkTheme: theme.dark(), // Tema oscuro
    );
  }
}

// Widget para detectar cambios en el tema del sistema
class ThemeListener extends ConsumerStatefulWidget {
  final Widget child;

  const ThemeListener({required this.child, Key? key}) : super(key: key);

  @override
  ConsumerState<ThemeListener> createState() => _ThemeListenerState();
}

class _ThemeListenerState extends ConsumerState<ThemeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Cuando cambia el brillo del sistema, actualiza el tema si está en modo sistema
    if (ref.read(themeProvider) == ThemeMode.system) {
      // Forzar una reconstrucción
      ref.invalidate(themeProvider);
    }
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Para usar el ThemeListener, modifica el main así:
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  runApp(
    const ProviderScope(
      child: ThemeListener(
        child: MyApp(),
      ),
    ),
  );
}
*/
