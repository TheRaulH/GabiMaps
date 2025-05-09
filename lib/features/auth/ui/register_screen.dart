import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/app/config/app_routes.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart'; 

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre, _apellido, _telefono, _direccion, _carrera;
  List<String>? _facultad;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final authUser = ref.read(authStateProvider).value;

    if (!_formKey.currentState!.validate() || authUser == null) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
      _error = null;
    });

    final user = UserModel(
      uid: authUser.uid,
      email: authUser.email ?? '',
      nombre: _nombre,
      apellido: _apellido,
      telefono: _telefono,
      direccion: _direccion,
      carrera: _carrera,
      facultad: _facultad,
      rol: 'usuario',
      fechaRegistro: DateTime.now(),
      photoURL: authUser.photoURL,
    );

    try {
      await ref
          .read(userOperationProvider(UserOperationType.createUser))
          .execute(user: user);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.mainapp);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completar Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Nombre"),
                        onSaved: (v) => _nombre = v,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Apellido",
                        ),
                        onSaved: (v) => _apellido = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Teléfono",
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (v) => _telefono = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Dirección",
                        ),
                        onSaved: (v) => _direccion = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Carrera"),
                        onSaved: (v) => _carrera = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Facultad (separadas por coma)",
                        ),
                        onSaved:
                            (v) =>
                                _facultad =
                                    v
                                        ?.split(',')
                                        .map((s) => s.trim())
                                        .where((s) => s.isNotEmpty)
                                        .toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text("Registrar"),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
