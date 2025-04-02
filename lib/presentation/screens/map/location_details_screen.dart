// location_details_screen.dart
import 'package:flutter/material.dart';

class LocationDetailsScreen extends StatelessWidget {
  const LocationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles de Ubicación')),
      body: const Center(child: Text('Detalles de la ubicación seleccionada')),
    );
  }
}
