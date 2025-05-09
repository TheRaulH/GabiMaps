import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _sent = false;
  String? _error;

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _error = null;
    });

    try {
      await ref
          .read(authOperationProvider(AuthOperationType.passwordReset))
          .execute(email: _email);

      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _sent
                ? const Center(
                  child: Text(
                    "Revisa tu correo para restablecer tu contraseña.",
                  ),
                )
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _sendResetEmail,
                        child: const Text("Enviar enlace de recuperación"),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
