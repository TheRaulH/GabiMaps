import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/location.dart';
import '../../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class AgregarUbicacionScreen extends ConsumerStatefulWidget {
  const AgregarUbicacionScreen({super.key});

  @override
  _AgregarUbicacionScreenState createState() => _AgregarUbicacionScreenState();
}

class _AgregarUbicacionScreenState
    extends ConsumerState<AgregarUbicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _latitudeController.text = latLng.latitude.toString();
      _longitudeController.text = latLng.longitude.toString();
    });
  }

  Future<bool> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLocation, zoom: 15.0),
          ),
        );
      }

      setState(() {
        _selectedLocation = currentLocation;
        _latitudeController.text = currentLocation.latitude.toString();
        _longitudeController.text = currentLocation.longitude.toString();
      });
    } catch (e) {
      if (mounted) {
        // Verifica si el widget está montado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación actual.'),
          ),
        );
      }
      print('Error getting location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await _requestLocationPermission()) {
        await _fetchCurrentLocation();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permisos de ubicación no otorgados.'),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Ubicación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0), // Centro inicial del mapa
                    zoom: 2.0,
                  ),
                  onTap: _onMapTapped,
                  markers:
                      _selectedLocation == null
                          ? {}
                          : {
                            Marker(
                              markerId: const MarkerId('selectedLocation'),
                              position: _selectedLocation!,
                            ),
                          },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la ubicación',
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final location = LocationEntity(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      latitude: double.parse(_latitudeController.text),
                      longitude: double.parse(_longitudeController.text),
                    );

                    await ref.read(saveLocationProvider).call(location);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ubicación guardada')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar Ubicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
