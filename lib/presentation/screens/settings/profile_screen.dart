// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user == null)
              const Center(child: Text("No hay usuario autenticado"))
            else ...[
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                  child:
                      user.photoURL == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildUserInfoRow(
                'Nombre',
                user.displayName ?? 'No especificado',
              ),
              _buildUserInfoRow('Apellido', 'No especificado'),
              _buildUserInfoRow('Email', user.email ?? 'No especificado'),
              _buildUserInfoRow('Tipo de Usuario', 'No especificado'),
              _buildUserInfoRow('Jefatura', 'No especificado'),
              _buildUserInfoRow('Carrera', 'No especificado'),
              _buildUserInfoRow('Teléfono', 'No especificado'),
              _buildUserInfoRow('Dirección', 'No especificado'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }
}
