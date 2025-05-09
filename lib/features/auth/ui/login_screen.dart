import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/app/config/app_routes.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart'; 

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authOperationProvider(AuthOperationType.signInWithEmail))
          .execute(email: _email, password: _password);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainapp);
      } else {
        // Si el usuario no se pudo autenticar, muestra un mensaje de error
        setState(
          () => _error = 'Error al iniciar sesión. Verifica tus credenciales.',
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authOperationProvider(AuthOperationType.signInWithGoogle))
          .execute();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        onSaved: (value) => _email = value!.trim(),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Ingresa un email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                        onSaved: (value) => _password = value!.trim(),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Ingresa una contraseña'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text("Iniciar Sesión"),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text("Continuar con Google"),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.resetPassword),
                        child: const Text("¿Olvidaste tu contraseña?"),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
