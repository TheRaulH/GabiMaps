import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/home/ui/saved.dart';
import 'package:gabimaps/features/map/ui/map_screen.dart';
import 'package:gabimaps/app/core/size_config.dart';
import 'package:gabimaps/features/posts/ui/posts_page.dart';
import 'package:gabimaps/features/user/ui/profile_screen.dart';

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

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final PageController pageController = PageController();

  final List<Widget> screens = [
    MapScreen(),
    GuardadosPage(),
    PostsPage(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    pageController.dispose();
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
  void animateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.decelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    // Obtener el tema actual basado en el modo de tema y el brillo de la plataforma
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Usar el color de fondo del tema en lugar de un color duro
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: screens,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: _buildBottomNav(isDarkMode, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDarkMode, ColorScheme colorScheme) {
    // Colores adaptados al tema
    final navBackgroundColor =
        isDarkMode
            ? colorScheme
                .surface //
            : colorScheme.secondaryContainer; //edor primario en modo claro

    final indicatorColor =
        isDarkMode
            ? colorScheme
                .onSurface //
            : colorScheme.onPrimary; // Color de superficie en modo claro
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.blockSizeHorizontal * 4.5,
        0,
        AppSizes.blockSizeHorizontal * 4.5,
        30,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent,
        elevation: 6,
        shadowColor: colorScheme.surface,
        child: Container(
          height: AppSizes.blockSizeHorizontal * 18,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: navBackgroundColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: AppSizes.blockSizeHorizontal * 3,
                right: AppSizes.blockSizeHorizontal * 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BottomNavBTN(
                      icon: Icons.home,
                      index: 0,
                      currentIndex: _currentIndex,
                      colorScheme: colorScheme,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                    BottomNavBTN(
                      icon: Icons.star,
                      index: 1,
                      currentIndex: _currentIndex,
                      colorScheme: colorScheme,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                    BottomNavBTN(
                      icon: Icons.access_alarm_outlined,
                      index: 2,
                      currentIndex: _currentIndex,
                      colorScheme: colorScheme,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                    BottomNavBTN(
                      icon: Icons.message_rounded,
                      index: 3,
                      currentIndex: _currentIndex,
                      colorScheme: colorScheme,
                      onPressed: (val) {
                        animateToPage(val);
                        setState(() => _currentIndex = val);
                      },
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.decelerate,
                top: 0,
                left: _animatedPositionLeftValue(_currentIndex),
                child: Column(
                  children: [
                    Container(
                      height: AppSizes.blockSizeHorizontal * 1.0,
                      width: AppSizes.blockSizeHorizontal * 12,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _animatedPositionLeftValue(int index) {
    switch (index) {
      case 0:
        return AppSizes.blockSizeHorizontal * 7.5;
      case 1:
        return AppSizes.blockSizeHorizontal * 28.5;
      case 2:
        return AppSizes.blockSizeHorizontal * 50;
      case 3:
        return AppSizes.blockSizeHorizontal * 71.5;
      default:
        return 0;
    }
  }
}

class BottomNavBTN extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ColorScheme colorScheme;
  final Function(int) onPressed;

  const BottomNavBTN({
    super.key,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.colorScheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return IconButton(
      onPressed: () => onPressed(index),
      icon: Icon(
        icon,         
        color:
            isActive
                ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
        size: isActive ? 28 : 24,
      ),
    );
  }
}
