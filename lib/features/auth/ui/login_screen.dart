import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/layout/main_app.dart'
    show MainApp;
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,title: const Text("Login"),centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await auth.login(emailController.text, passwordController.text);
                if (context.mounted) {
                  // ✅ Verifica si el contexto sigue montado antes de navegar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainApp()),
                  );
                }
              },
              child: const Text("Iniciar Sesión"),
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.loginWithGoogle();
                if (context.mounted) {
                  // ✅ Verifica si el contexto sigue montado antes de navegar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainApp()),
                  );
                }
              },
              child: const Text("Iniciar con Google"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}
