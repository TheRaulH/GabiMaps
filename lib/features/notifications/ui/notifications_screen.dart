import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: const Center(
        child: Text(
          'Contenido de la pantalla de notificaciones aquí',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
