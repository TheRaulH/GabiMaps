import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapControlsWidget extends StatelessWidget {
  final MapController mapController;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCurrentLocation; 
  final LatLng? currentPosition;
  final double currentZoom;

  const MapControlsWidget({
    super.key,
    required this.mapController,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCurrentLocation,
 
    this.currentPosition,
    required this.currentZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botones flotantes de zoom y ubicación
        Positioned(
          right: 16,
          bottom: 96,
          child: Column(
            children: [
              // Botón de seguimiento (nuevo)
              FloatingActionButton(
                heroTag: 'location',
                mini: true,
                onPressed: onCurrentLocation,
                child: const Icon(Icons.gps_fixed),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoomIn',
                onPressed: onZoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoomOut',
                onPressed: onZoomOut,
                child: const Icon(Icons.remove),
              ),
               
            ],
          ),
        ),

        //indicador de nivel de zoom
        Positioned(
          left: 16,
          bottom: 150,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorScheme.highContrastDark().primaryFixed.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Zoom: ${currentZoom.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              
            ),
          ),
        ),

        // Indicador de coordenadas
        if (currentPosition != null)
          Positioned(
            left: 16,
            bottom: 96,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorScheme.highContrastDark().primaryFixed,
                
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lat: ${currentPosition!.latitude.toStringAsFixed(5)}\n'
                'Lng: ${currentPosition!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                
            
              ),
            ),
          ),
      ],
    );
  }
}
