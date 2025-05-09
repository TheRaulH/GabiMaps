import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/layout/main_app.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/ui/login_screen.dart';

// Provider para controlar la animación del splash
final splashProvider = StateNotifierProvider<SplashNotifier, bool>((ref) {
  return SplashNotifier();
});

class SplashNotifier extends StateNotifier<bool> {
  SplashNotifier() : super(true);

  void hideSplash() => state = false;
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Temporizador para mostrar el contenido principal después de la animación
    Future.delayed(const Duration(milliseconds: 3000), () {
      ref.read(splashProvider.notifier).hideSplash();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showSplash = ref.watch(splashProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(20, 1, 127, 1),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(20, 1, 127, 1), // Color de inicio del degradado
              Colors.purple, // Otro color para el degradado
              Colors.deepPurpleAccent, // Un tercer color (opcional)
            ],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child:
              showSplash
                  ? _SplashLoading(
                    fadeAnimation: _fadeAnimation,
                    scaleAnimation: _scaleAnimation,
                  )
                  : _MainContent(user: user),
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final dynamic user;

  const _MainContent({required this.user});

  @override
  Widget build(BuildContext context) {
    // 👤 Sesión activa
    if (user != null) {
      return const MainApp();
    }

    // ❌ No autenticado
    return LoginScreen();
  }
}

class _SplashLoading extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _SplashLoading({
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Center(
            // Wrap the Column with Center
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: scaleAnimation,
                  child: const Image(
                    image: AssetImage('assets/icon/app_icon.png'),
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 30),
                _buildLoadingIndicator(),
                const SizedBox(height: 20),
                _buildAppName(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: null, // Indicador indeterminado
            strokeWidth: 4.0,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: const Text(
            'GabiMaps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }
}
