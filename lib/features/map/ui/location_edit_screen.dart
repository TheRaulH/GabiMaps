// map/ui/location_edit_screen.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gabimaps/app/core/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:gabimaps/features/map/data/location.dart';
import 'package:gabimaps/features/map/providers/location_provider.dart';


class LocationEditScreen extends ConsumerStatefulWidget {
  final Location? location;
  const LocationEditScreen({super.key, this.location});

  @override
  ConsumerState<LocationEditScreen> createState() => _LocationEditScreenState();
}

class _LocationEditScreenState extends ConsumerState<LocationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _layerController;
  late TextEditingController _imageUrlController;
  List<String> _categories = [];
  String _newCategory = '';

  // Map related variables
  final MapController _mapController = MapController();
  LatLng _selectedPosition = const LatLng(-17.775701, -63.197302);
  final List<Marker> _markers = [];
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _updateMarker();
  }

  void _initializeControllers() {
    final loc = widget.location;
    _nameController = TextEditingController(text: loc?.name ?? '');
    _descriptionController = TextEditingController(
      text: loc?.description ?? '',
    );
    _addressController = TextEditingController(text: loc?.address ?? '');

    // Initialize position
    _selectedPosition =
        loc != null
            ? LatLng(loc.latitude, loc.longitude)
            : const LatLng(-17.775701, -63.197302);

    _latController = TextEditingController(
      text: _selectedPosition.latitude.toStringAsFixed(6),
    );
    _lngController = TextEditingController(
      text: _selectedPosition.longitude.toStringAsFixed(6),
    );
    _layerController = TextEditingController(
      text: loc?.layer.toString() ?? '0',
    );
    _imageUrlController = TextEditingController(text: loc?.imageUrl ?? '');
    _categories = loc?.categories?.toList() ?? [];
  }

  void _updateMarker() {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          point: _selectedPosition,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      );
    });
  }

  void _updatePositionFromMap(LatLng newPosition) {
    setState(() {
      _selectedPosition = newPosition;
      _latController.text = newPosition.latitude.toStringAsFixed(6);
      _lngController.text = newPosition.longitude.toStringAsFixed(6);
      _updateMarker();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _layerController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.location == null ? 'Nueva Ubicación' : 'Editar Ubicación',
          ),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.edit), text: 'Detalles'),
              Tab(icon: Icon(Icons.map), text: 'Mapa'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLocation,
              tooltip: 'Guardar',
            ),
          ],
        ),
        body: TabBarView(children: [_buildFormTab(), _buildMapTab()]),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveLocation,
          tooltip: 'Guardar ubicación',
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildCoordinatesCard(),
            const SizedBox(height: 16),
            _buildMediaCard(),
            const SizedBox(height: 16),
            _buildCategoriesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información básica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.place),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 16),
            // TextFormField(
            //   controller: _layerController,
            //   decoration: const InputDecoration(
            //     labelText: 'Capa',
            //     prefixIcon: Icon(Icons.layers),
            //   ),
            //   keyboardType: TextInputType.number,
            //   validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            // ),
            //hacer un selector de capas usando un select
            // const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: int.parse(_layerController.text),
              decoration: const InputDecoration(
                labelText: 'Capa',
                prefixIcon: Icon(Icons.layers),
              ),
              items: List.generate(3, (index) => index).map((layer) {
                return DropdownMenuItem<int>(
                  value: layer,
                  child: Text('Capa $layer'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _layerController.text = value.toString();
                  });
                }
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coordenadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      prefixIcon: Icon(Icons.north),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => _validateCoordinate(value),
                    onChanged: (value) {
                      final lat = double.tryParse(value);
                      if (lat != null) {
                        _updatePositionFromMap(
                          LatLng(lat, _selectedPosition.longitude),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      prefixIcon: Icon(Icons.east),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => _validateCoordinate(value),
                    onChanged: (value) {
                      final lng = double.tryParse(value);
                      if (lng != null) {
                        _updatePositionFromMap(
                          LatLng(_selectedPosition.latitude, lng),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
             
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multimedia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mostrar imagen actual o placeholder
            _buildImagePreview(),
            const SizedBox(height: 16),

            // Botones para seleccionar imagen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                if (_imageUrlController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteImage,
                    tooltip: 'Eliminar imagen',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child:
          _imageUrlController.text.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrlController.text,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholder(),
                ),
              )
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No hay imagen seleccionada',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Subir imagen a Firebase Storage
        final imageUrl = await _uploadImageToFirebase(File(pickedFile.path));

        // Cerrar loading
        if (mounted) Navigator.pop(context);

        // Actualizar estado
        setState(() {
          _imageUrlController.text = imageUrl;
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      // Crear referencia al storage
      final storage = FirebaseStorage.instance;
      final fileName = 'locations/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child(fileName);

      // Subir el archivo
      await ref.putFile(imageFile);

      // Obtener la URL de descarga
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> _deleteImage() async {
    try {
      if (_imageUrlController.text.isEmpty) return;

      // Mostrar diálogo de confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Eliminar imagen'),
              content: const Text(
                '¿Estás seguro de que quieres eliminar esta imagen?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true) {
        // Eliminar de Firebase Storage
        await _deleteImageFromFirebase(_imageUrlController.text);

        // Actualizar estado
        setState(() {
          _imageUrlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar imagen: $e')));
      }
    }
  }

  Future<void> _deleteImageFromFirebase(String imageUrl) async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  Widget _buildCategoriesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mostrar chips de categorías seleccionadas
            if (_categories.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _categories
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeCategory(category),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Selector de categorías
            _buildCategorySelector(),

            // Opción para añadir categoría personalizada
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Añadir categoría personalizada',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nueva categoría',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.create),
                    ),
                    onChanged: (value) => _newCategory = value,
                    onSubmitted: (value) => _addCustomCategory(value),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 32),
                  color: Theme.of(context).primaryColor,
                  onPressed: () => _addCustomCategory(_newCategory),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar categorías predefinidas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Filtro de búsqueda para categorías predefinidas
        TextField(
          decoration: const InputDecoration(
            labelText: 'Buscar categorías',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        // Lista de categorías disponibles
        SizedBox(
          height: 120,
          child: SingleChildScrollView(
            child: Column(
              children:
                  AppConstants.locationCategories
                      .where((category) => !_categories.contains(category))
                      .map(
                        (category) => ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -4),
                          title: Text(category),
                          trailing: const Icon(Icons.add),
                          onTap: () => _addPredefinedCategory(category),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _addPredefinedCategory(String category) {
    if (!_categories.contains(category)) {
      setState(() {
        _categories.add(category);
      });
    }
  }

  void _addCustomCategory(String category) {
    final trimmedCategory = category.trim();
    if (trimmedCategory.isNotEmpty && !_categories.contains(trimmedCategory)) {
      setState(() {
        _categories.add(trimmedCategory);
        _newCategory = '';
        FocusScope.of(context).unfocus();
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedPosition,
            initialZoom: _currentZoom,
            onTap: (_, point) => _updatePositionFromMap(point),
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() => _currentZoom = position.zoom);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gabimaps.app',
            ),
            MarkerLayer(markers: _markers),
          ],
        ),
        _buildMapControls(),
        _buildPositionInfoCard(),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'zoomIn',
            onPressed:
                () => _mapController.move(_selectedPosition, _currentZoom + 1),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoomOut',
            onPressed:
                () => _mapController.move(_selectedPosition, _currentZoom - 1),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed:
                () => _mapController.move(_selectedPosition, _currentZoom),
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionInfoCard() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubicación actual',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}'),
              Text('Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}'),
            ],
          ),
        ),
      ),
    );
  }


  String? _validateCoordinate(String? value) {
    if (value?.isEmpty ?? true) return 'Requerido';
    final num = double.tryParse(value!);
    if (num == null) return 'Número inválido';
    if (num < -90 || num > 90) return 'Latitud debe estar entre -90 y 90';
    return null;
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete los campos requeridos'),
        ),
      );
      return;
    }

    final location = Location(
      id: widget.location?.id ?? '',
      name: _nameController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      position: GeoPoint(
        _selectedPosition.latitude,
        _selectedPosition.longitude,
      ),
      layer: int.parse(_layerController.text),
      imageUrl:
          _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      categories: _categories.isEmpty ? null : _categories,
      rating: widget.location?.rating,
      reviewCount: widget.location?.reviewCount,
      createdAt: widget.location?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final notifier = ref.read(locationsProvider.notifier);
      if (widget.location == null) {
        await notifier.addLocation(location);
      } else {
        await notifier.updateLocation(location);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación guardada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }
}
