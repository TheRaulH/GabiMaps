import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabimaps/layout/main_app.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/ui/login_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(20, 1, 127, 1),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          // Usuario autenticado
          // Actualizar el estado en Riverpod después de la construcción
          Future.microtask(
            () => ref.read(authProvider.notifier).updateUser(snapshot.data),
          );
          return const MainApp();
        } else {
          // Usuario no autenticado
          // Actualizar el estado en Riverpod después de la construcción
          Future.microtask(
            () => ref.read(authProvider.notifier).updateUser(null),
          );
          return LoginScreen();
        }
      },
    );
  }
}
