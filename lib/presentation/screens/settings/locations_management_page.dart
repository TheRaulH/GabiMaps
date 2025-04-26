// locations_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gabimaps/domain/entities/location.dart';
import 'package:gabimaps/presentation/providers/location_provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class LocationsManagementPage extends ConsumerStatefulWidget {
  const LocationsManagementPage({super.key});

  @override
  ConsumerState<LocationsManagementPage> createState() =>
      _LocationsManagementPageState();
}

class _LocationsManagementPageState
    extends ConsumerState<LocationsManagementPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Cargar las ubicaciones al iniciar
    Future.microtask(
      () => ref.read(locationsProvider.notifier).loadLocations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationsState = ref.watch(locationsProvider);
    final filteredLocations = ref.watch(filteredLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ubicaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => ref.read(locationsProvider.notifier).loadLocations(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar ubicaciones',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(locationSearchProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: _buildLocationsList(locationsState, filteredLocations),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLocationFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLocationsList(
    LocationsState state,
    List<Location> filteredLocations,
  ) {
    if (state is LocationsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is LocationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => ref.read(locationsProvider.notifier).loadLocations(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } else if (filteredLocations.isEmpty) {
      return const Center(child: Text('No se encontraron ubicaciones'));
    }

    return ListView.builder(
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        final location = filteredLocations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading:
                location.imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        location.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.location_on, size: 40),
                      ),
                    )
                    : const CircleAvatar(child: Icon(Icons.location_on)),
            title: Text(location.name),
            subtitle: Text(
              location.address ?? 'Sin dirección',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showLocationFormDialog(context, location),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, location),
                ),
              ],
            ),
            onTap: () => _showLocationDetails(context, location),
          ),
        );
      },
    );
  }

  void _showLocationDetails(BuildContext context, Location location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (location.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            location.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const SizedBox(
                                  height: 200,
                                  child: Center(child: Icon(Icons.error)),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        location.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (location.address != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                location.address!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (location.description != null) ...[
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(location.description!),
                        const SizedBox(height: 16),
                      ],
                      if (location.categories != null &&
                          location.categories!.isNotEmpty) ...[
                        Text(
                          'Categorías',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              location.categories!.map((category) {
                                return Chip(
                                  label: Text(category),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  visualDensity: VisualDensity.compact,
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Coordenadas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Latitud: ${location.latitude}'),
                      Text('Longitud: ${location.longitude}'),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                location.latitude,
                                location.longitude,
                              ),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(location.id),
                                position: LatLng(
                                  location.latitude,
                                  location.longitude,
                                ),
                                infoWindow: InfoWindow(title: location.name),
                              ),
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (location.createdAt != null ||
                          location.updatedAt != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (location.createdAt != null)
                              Text(
                                'Creado: ${DateFormat('dd/MM/yyyy').format(location.createdAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (location.updatedAt != null)
                              Text(
                                'Actualizado: ${DateFormat('dd/MM/yyyy').format(location.updatedAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _confirmDelete(BuildContext context, Location location) {
    // Captura el ScaffoldMessengerState usando el context de la página principal
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            // dialogContext es el contexto del builder del diálogo
            title: const Text('Eliminar ubicación'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${location.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Cierra el diálogo

                  try {
                    await ref
                        .read(locationsProvider.notifier)
                        .deleteLocation(location.id);

                    // Usa la instancia capturada del messenger, no necesitas context aquí
                    // y no necesitas chequear mounted porque el messenger es del Scaffold principal
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '${location.name} eliminado correctamente',
                        ),
                      ),
                    );
                  } catch (e) {
                    // Usa la instancia capturada del messenger
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error al eliminar: $e')),
                    );
                  }
                  // Ya no necesitas el if (mounted) aquí al usar la instancia de messenger
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _showLocationFormDialog(
    BuildContext context, [
    Location? existingLocation,
  ]) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            child: LocationFormDialog(existingLocation: existingLocation),
          ),
    );
  }
}

class LocationFormDialog extends ConsumerStatefulWidget {
  final Location? existingLocation;

  const LocationFormDialog({super.key, this.existingLocation});

  @override
  ConsumerState<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends ConsumerState<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _layerController = TextEditingController(
    text: '1',
  ); // valor por defecto

  LatLng? _selectedPosition;
  Set<Marker> _markers = {};
  List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Edificio',
    'Facultad',
    'Biblioteca',
    'Cafetería',
    'Deportes',
    'Estacionamiento',
    'Laboratorio',
    'Aula',
  ];
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  final GoogleMapController? _mapController = null;

  @override
  void initState() {
    super.initState();
    if (widget.existingLocation != null) {
      _nameController.text = widget.existingLocation!.name;
      _descriptionController.text = widget.existingLocation!.description ?? '';
      _addressController.text = widget.existingLocation!.address ?? '';
      _selectedPosition = LatLng(
        widget.existingLocation!.latitude,
        widget.existingLocation!.longitude,
      );
      _selectedCategories = widget.existingLocation!.categories?.toList() ?? [];
      _existingImageUrl = widget.existingLocation!.imageUrl;

      // Configurar el marcador inicial
      _markers = {
        Marker(
          markerId: const MarkerId('selected_position'),
          position: _selectedPosition!,
        ),
      };
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _layerController.dispose(); // liberar
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _existingImageUrl;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('locations')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final uploadTask = await storageRef.putFile(_imageFile!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
      return null;
    }
  }

  Future<void> _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una ubicación en el mapa'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Subir imagen si existe
        final imageUrl = await _uploadImage();

        final geoPoint = GeoPoint(
          _selectedPosition!.latitude,
          _selectedPosition!.longitude,
        );

        if (widget.existingLocation != null) {
          // Actualizar ubicación existente
          final updatedLocation = Location(
            id: widget.existingLocation!.id,
            name: _nameController.text,
            position: geoPoint,
            layer: int.parse(_layerController.text),
            description:
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
            address:
                _addressController.text.isNotEmpty
                    ? _addressController.text
                    : null,
            categories:
                _selectedCategories.isNotEmpty ? _selectedCategories : null,
            imageUrl: imageUrl,
            rating: widget.existingLocation!.rating,
            reviewCount: widget.existingLocation!.reviewCount,
            createdAt: widget.existingLocation!.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await ref
              .read(locationsProvider.notifier)
              .updateLocation(updatedLocation);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ubicación actualizada correctamente'),
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          // Crear nueva ubicación
          final newLocation = Location(
            id: '', // El ID lo asigna Firestore
            name: _nameController.text,
            position: geoPoint,
            layer: int.parse(_layerController.text),
            description:
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
            address:
                _addressController.text.isNotEmpty
                    ? _addressController.text
                    : null,
            categories:
                _selectedCategories.isNotEmpty ? _selectedCategories : null,
            imageUrl: imageUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await ref.read(locationsProvider.notifier).addLocation(newLocation);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ubicación agregada correctamente')),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingLocation == null
                ? 'Agregar Ubicación'
                : 'Editar Ubicación',
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen de la ubicación
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image:
                                    _imageFile != null
                                        ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                        : _existingImageUrl != null
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            _existingImageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  _imageFile == null &&
                                          _existingImageUrl == null
                                      ? const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_a_photo, size: 40),
                                            SizedBox(height: 8),
                                            Text('Agregar imagen'),
                                          ],
                                        ),
                                      )
                                      : Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 16,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 16,
                                              ),
                                              color: Colors.white,
                                              onPressed: _pickImage,
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campos del formulario
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Selector de categorías
                        Text(
                          'Categorías',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _availableCategories.map((category) {
                                final isSelected = _selectedCategories.contains(
                                  category,
                                );
                                return FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category);
                                      } else {
                                        _selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Selector de ubicación en el mapa
                        Text(
                          'Ubicación en el mapa *',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toca en el mapa para seleccionar la ubicación',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target:
                                    _selectedPosition ??
                                    const LatLng(
                                      -17.777438043503892,
                                      -63.190263743504275,
                                    ), // CDMX por defecto
                                zoom: 15,
                              ),
                              onMapCreated: (controller) {
                                // No se puede asignar directamente debido a que _mapController es final
                                // Pero podríamos usar otro enfoque si necesitamos el controlador
                              },
                              markers: _markers,
                              onTap: (position) {
                                setState(() {
                                  _selectedPosition = position;
                                  _markers = {
                                    Marker(
                                      markerId: const MarkerId(
                                        'selected_position',
                                      ),
                                      position: position,
                                    ),
                                  };
                                });
                              },
                            ),
                          ),
                        ),
                        if (_selectedPosition != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, '
                            'Long: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 24),

                        const SizedBox(height: 16),
                        Text(
                          'Capa de visualización *',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _layerController.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Seleccionar capa',
                          ),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('Capa 1')),
                            DropdownMenuItem(value: '2', child: Text('Capa 2')),
                            DropdownMenuItem(value: '3', child: Text('Capa 3')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _layerController.text = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecciona una capa';
                            }
                            return null;
                          },
                        ),

                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _saveLocation,
                              child: Text(
                                widget.existingLocation == null
                                    ? 'Agregar'
                                    : 'Actualizar',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
