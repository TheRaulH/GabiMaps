import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: const Center(
        child: Text(
          'Contenido de la pantalla del mapa aquí',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
