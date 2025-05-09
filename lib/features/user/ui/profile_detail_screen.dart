import 'package:flutter/material.dart';
import 'package:gabimaps/features/user/data/user_model.dart';

class ProfileDetailScreen extends StatelessWidget {
  final UserModel user;

  const ProfileDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child:
                    user.photoURL == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailItem(
              'Nombre completo',
              '${user.nombre ?? ''} ${user.apellido ?? ''}'.trim(),
            ),
            _buildDetailItem('Email', user.email),
            _buildDetailItem('Rol', user.rol),
            _buildDetailItem('Teléfono', user.telefono ?? 'No especificado'),
            _buildDetailItem('Dirección', user.direccion ?? 'No especificada'),
            _buildDetailItem('Carrera', user.carrera ?? 'No especificada'),
            _buildDetailItem(
              'Facultad',
              user.facultad?.join(', ') ?? 'No especificada',
            ),
            _buildDetailItem(
              'Fecha de Registro',
              user.fechaRegistro?.toLocal().toString().split(' ').first ??
                  'No especificada',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
