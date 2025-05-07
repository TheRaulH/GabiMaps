import 'package:flutter/material.dart';

class CategoryMarkerIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryMarkerIcon({super.key, required this.category, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> iconMap = {
      'Facultad': 'assets/pois_icons/marcador.png',
      'Biblioteca': 'assets/pois_icons/biblioteca.png',
      'Cafetería': 'assets/pois_icons/cafeteria.png',
      'Laboratorio': 'assets/pois_icons/laboratorio.png',
      'Edificio': 'assets/pois_icons/edificio.png',
      'Aula': 'assets/pois_icons/aula.png',
      'Estacionamiento': 'assets/pois_icons/estacionamiento.png',
      'Deportes': 'assets/pois_icons/deportes.png',
    };

    final iconPath = iconMap[category] ?? 'assets/pois_icons/default.png';

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        iconPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.location_on, size: size, color: Colors.red);
        },
      ),
    );
  }
}
