import 'dart:async';
import 'dart:ui' as ui; // Importa dart:ui con un alias
import 'package:gabimaps/presentation/widgets/category_marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/presentation/providers/location_provider.dart';
import 'package:gabimaps/presentation/screens/settings/settings_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  StreamSubscription<MapEvent>? _mapEventSubscription;
  LatLng? _currentPosition;
  double _currentZoom = 14.0; // Inicializa el zoom en 14.0
  final ValueNotifier<double> _zoomNotifier = ValueNotifier(14.0);

  int _getLayerForZoom(double zoom) {
    if (zoom <= 18) return 1;
    if (zoom < 19) return 2;
    return 3;
  }

  // Posición inicial del mapa
  final LatLng _initialPosition = const LatLng(
    -17.777438043503892,
    -63.190263743504275,
  ); // Coordenadas iniciales del mapa

  Uint8List? _customIconBytes;

  /*
  BitmapDescriptor?
  _customIcon; // Variable para almacenar el icono personalizado

  El icono se define como Widget directamente
 */
  @override
  void initState() {
    super.initState();

    // 1. Cargar ubicaciones apenas arranca la pantalla
    Future.microtask(() {
      final locationsState = ref.read(locationsProvider);
      if (locationsState is! LocationsLoaded &&
          locationsState is! LocationsLoading) {
        ref.read(locationsProvider.notifier).loadLocations();
      }
    });

    // 2. Escuchar cambios de búsqueda
    _searchController.addListener(_onSearchChanged);

    // 3. ESCUCHAR movimientos del mapa
    _mapEventSubscription = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove || event is MapEventMoveEnd) {
        final center = _mapController.camera.center;
        final zoom = _mapController.camera.zoom;
        setState(() {
          _currentPosition = LatLng(center.latitude, center.longitude);
          _currentZoom = zoom;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están desactivados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Los permisos de ubicación están denegados permanentemente.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final zoom = _mapController.camera.zoom;

    final newPosition = LatLng(position.latitude, position.longitude);

    if (mounted) {
      setState(() {
        _currentPosition = newPosition;
        _mapController.move(_currentPosition!, zoom);
      });
    }
  }

  /*
  // Función asíncrona para cargar el icono personalizado
  Future<void> _loadCustomMarkerIcon() async {
    final ByteData byteData = await rootBundle.load(
      'assets/marcador.png',
    ); // Reemplaza con la ruta de tu imagen
    final ui.Codec codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: 80, // Opcional: ajusta el tamaño del icono
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    final ByteData? resizedByteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (resizedByteData == null) {
      return;
    }
    _customIcon = BitmapDescriptor.fromBytes(
      resizedByteData.buffer.asUint8List(),
    );
  }
 Ya no es necesario, ya que el icono se define como Widget directamente
  */

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Limpiar listener

    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Listener para actualizar el provider de búsqueda
  void _onSearchChanged() {
    // Usamos ref.read para modificar el estado del provider
    ref.read(locationSearchProvider.notifier).state = _searchController.text;
  }

  void _zoomIn() {
    final newZoom = (_mapController.camera.zoom + 1).clamp(3.0, 20.0);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    final newZoom = (_mapController.camera.zoom - 1).clamp(3.0, 20.0);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  /*
  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    final zoom = await controller.getZoomLevel();
    _zoomNotifier.value = zoom;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _currentZoom = position.zoom;
    });
  }
*/
  void _searchLocation() {
    final searchText = _searchController.text;
    if (searchText.isNotEmpty) {
      final currentFilteredLocations = ref.read(filteredLocationsProvider);
      if (currentFilteredLocations.isNotEmpty) {
        final firstLocation = currentFilteredLocations.first;

        _mapController.move(
          LatLng(firstLocation.latitude, firstLocation.longitude),
          _currentZoom,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Centrando en: ${firstLocation.name}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron ubicaciones con esa búsqueda'),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa un texto para buscar'),
          ),
        );
      }
    }
  }

  // Muestra los detalles completos de la ubicación
  void _showLocationDetails(BuildContext context, location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      // Indicador de arrastre
                      Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Título
                      Text(
                        location.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Categorías con chips (corregido: usando un builder manual en lugar de map)
                      if (location.categories != null &&
                          location.categories!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Construimos manualmente la lista de widgets
                            for (final category in location.categories!)
                              Chip(
                                label: Text(category),
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Dirección
                      if (location.address != null) ...[
                        Text(
                          'Dirección:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(location.address!),
                        const SizedBox(height: 12),
                      ],

                      // Descripción
                      if (location.description != null) ...[
                        Text(
                          'Descripción:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(location.description!),
                        const SizedBox(height: 12),
                      ],

                      // Mostrar rating si está disponible
                      if (location.rating != null) ...[
                        Text(
                          'Valoración:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            Text('${location.rating} '),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            if (location.reviewCount != null)
                              Text(' (${location.reviewCount} reseñas)'),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Fecha de actualización
                      if (location.updatedAt != null) ...[
                        Text(
                          'Última actualización:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${location.updatedAt!.day}/${location.updatedAt!.month}/${location.updatedAt!.year}',
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Coordenadas
                      Text(
                        'Coordenadas:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${location.latitude}, ${location.longitude}'),
                      const SizedBox(height: 24),

                      // Imagen si está disponible
                      if (location.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            location.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_mapController != null) {
                                _mapController.move(
                                  LatLng(location.latitude, location.longitude),
                                  18.0, // Zoom fijo en 18.0
                                );
                              }
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Centrar en mapa'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Aquí implementarías la funcionalidad para compartir la ubicación
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funcionalidad de compartir en desarrollo',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Compartir'),
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

  // Modifica _toggleFilter para actualizar el provider de categorías seleccionadas
  void _toggleFilter(String filter) {
    // Usamos ref.read para acceder al notifier del provider
    final selectedFiltersNotifier = ref.read(
      selectedCategoriesProvider.notifier,
    );
    final currentFilters = Set<String>.from(
      selectedFiltersNotifier.state,
    ); // Clonar el set

    setState(() {
      // setState es necesario para reconstruir la UI de los chips
      if (currentFilters.contains(filter)) {
        currentFilters.remove(filter);
      } else {
        currentFilters.add(filter);
      }
      // Actualizar el estado del provider
      selectedFiltersNotifier.state = currentFilters;
    });

    // El filtrado del mapa ocurre automáticamente al actualizar el provider
    // Puedes eliminar este SnackBar si lo deseas
    // ScaffoldMessenger.of(context).showSnackBar(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('Filtro aplicado: $filter')));
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observar el estado de carga/error de las ubicaciones
    final locationsState = ref.watch(locationsProvider);
    // Observar la lista de ubicaciones filtradas por búsqueda y categoría
    final filteredLocations = ref.watch(filteredLocationsProvider);
    // Observar los filtros seleccionados para actualizar la UI de los chips
    final selectedFilters = ref.watch(selectedCategoriesProvider);

    // Definir la lista de filtros disponibles (puedes obtenerla de LocationFormDialog o definirla aquí)
    final List<String> availableFilters = [
      'Edificio',
      'Facultad',
      'Biblioteca',
      'Cafetería',
      'Deportes',
      'Estacionamiento',
      'Laboratorio',
      'Aula',
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda y botón de perfil
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar ubicación',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _searchLocation(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón para ir a la pantalla de perfil
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        //icono de hamburgesa
                        Icons.view_list_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      onPressed: _navigateToProfile,
                      tooltip: 'Perfil',
                    ),
                  ),
                ],
              ),
            ),

            // Filtros horizontales
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableFilters.length,
                itemBuilder: (context, index) {
                  final filter = availableFilters[index];
                  final isSelected = selectedFilters.contains(filter);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => _toggleFilter(filter),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      selectedColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Mapa
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: _zoomNotifier,
                builder: (context, zoom, _) {
                  final currentLayer = _getLayerForZoom(zoom);
                  final locationsState = ref.watch(locationsProvider);
                  final filteredLocations = ref.watch(
                    filteredLocationsProvider,
                  );

                  List<Marker> markers = [];
                  if (locationsState is LocationsLoaded) {
                    final zoom = _zoomNotifier.value;
                    final currentLayer = _getLayerForZoom(zoom);
                    final hasCategoryFilter = selectedFilters.isNotEmpty;

                    markers =
                        filteredLocations
                            .where((location) {
                              if (hasCategoryFilter) {
                                // Mostrar si alguna categoría de la ubicación coincide con las seleccionadas
                                return location.categories?.any(
                                      selectedFilters.contains,
                                    ) ??
                                    false;
                              } else {
                                // Sin filtros: aplicar lógica de capas
                                return location.layer == 1 ||
                                    location.layer <= currentLayer;
                              }
                            })
                            .map((location) {
                              final markerSize =
                                  (_currentZoom.clamp(13.0, 18.0) - 10) * 4;
                              return Marker(
                                point: LatLng(
                                  location.latitude,
                                  location.longitude,
                                ),
                                width: markerSize,
                                height: markerSize,
                                child: GestureDetector(
                                  onTap:
                                      () => _showLocationDetails(
                                        context,
                                        location,
                                      ),
                                  child: CategoryMarkerIcon(
                                    category:
                                        location.categories?.first ?? 'default',
                                    size: markerSize,
                                  ),
                                ),
                              );
                            })
                            .toList();
                  }

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition ?? _initialPosition,
                          initialZoom: _currentZoom,
                          minZoom: 3,
                          maxZoom: 20,
                          onPositionChanged: (position, hasGesture) {
                            if (mounted && position.center != null) {
                              _currentPosition = position.center!;
                              _currentZoom = position.zoom ?? _currentZoom;
                              _zoomNotifier.value = _currentZoom;
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),

                          MarkerLayer(markers: markers.toList()),
                        ],
                      ),

                      // Botones flotantes
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'zoomIn',
                              onPressed: _zoomIn,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoomOut',
                              onPressed: _zoomOut,
                              child: const Icon(Icons.remove),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              onPressed: _getCurrentLocation,
                              tooltip: 'Ubicación actual',
                              child: const Icon(Icons.my_location),
                            ),
                          ],
                        ),
                      ),

                      // Indicador de coordenadas
                      if (_currentPosition != null)
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),

                      // Estados especiales
                      if (locationsState is LocationsLoading)
                        const Center(child: CircularProgressIndicator()),

                      if (locationsState is LocationsError)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error al cargar ubicaciones: ${locationsState.message}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                      if (locationsState is LocationsLoaded &&
                          filteredLocations.isEmpty &&
                          _searchController.text.isNotEmpty)
                        const Center(
                          child: Text(
                            'No se encontraron ubicaciones con esos filtros',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
