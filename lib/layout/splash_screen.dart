import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/app/config/app_routes.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';

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
  bool _animationCompleted = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Iniciar el proceso de verificación después de que las animaciones hayan empezado
    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _animationCompleted = true);
         
      }
    });
  }

  void _initializeAnimations() {
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
  }

  Future<void> _checkUserStatus() async {
    if (_navigated || !_animationCompleted) return;

    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) return;
    if (authState.hasError) {
      // Manejo opcional de errores
      _navigate(AppRoutes.login);
      return;
    }

    final authUser = authState.value; 

    if (authUser == null) {
      // No hay usuario autenticado
      _navigate(AppRoutes.login);
      return;
    }

    final uid = authUser.uid;
    final userExists =
        await ref
                .read(userOperationProvider(UserOperationType.userExists))
                .execute(uid: uid)
            as bool;

    if (userExists) {
      // Usuario autenticado y tiene documento en Firestore
      _navigate(AppRoutes.mainapp);
    } else {
      // Usuario autenticado pero no tiene datos extendidos
      _navigate(AppRoutes.register);
    }
    _navigated = true;
  }

  void _navigate(String route) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkUserStatus();
      });
    }
    return Scaffold(
      backgroundColor: const Color.fromRGBO(20, 1, 127, 1),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red,
              Color.fromRGBO(136, 0, 0, 1),
              Colors.black,
              Color.fromRGBO(0, 48, 95, 1),
              Color.fromRGBO(0, 102, 204, 1),
              
              
            ],
          ),
        ),
        child: Center(
          child: _SplashLoading(
            fadeAnimation: _fadeAnimation,
            scaleAnimation: _scaleAnimation,
          ),
        ),
      ),
    );
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
    return SizedBox(
      width: 60,
      height: 60,
      child: CircularProgressIndicator(
        value: null,
        strokeWidth: 4.0,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildAppName() {
    return const Text(
      'GabiMaps',
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
