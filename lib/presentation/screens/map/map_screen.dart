import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/presentation/providers/location_provider.dart';
import 'package:gabimaps/presentation/screens/settings/settings_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  final ValueNotifier<double> _zoomNotifier = ValueNotifier(14.0);

  int _getLayerForZoom(double zoom) {
    if (zoom <= 18) return 1;
    if (zoom < 19) return 2;
    return 3;
  }

  // Estado para filtros seleccionados
  //final Set<String> _selectedFilters = {};

  // Lista de filtros disponibles
  //

  // Posición inicial del mapa
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-17.777438043503892, -63.190263743504275),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    // Cargar las ubicaciones al iniciar la pantalla del mapa si no están ya cargadas
    Future.microtask(() {
      // Usamos ref.read para acceder al notifier una vez al inicio
      final locationsState = ref.read(locationsProvider);
      if (locationsState is! LocationsLoaded &&
          locationsState is! LocationsLoading) {
        ref.read(locationsProvider.notifier).loadLocations();
      }
    });

    // Escucha los cambios en el controlador de búsqueda para actualizar el provider
    _searchController.addListener(_onSearchChanged);
  }

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

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    final zoom = await controller.getZoomLevel();
    _zoomNotifier.value = zoom;
  }

  void _searchLocation() {
    // Implementar búsqueda de ubicación (opcional: centrar mapa en resultado)
    // Aquí se podría integrar con API de Places o geocodificación
    final searchText = _searchController.text;
    if (searchText.isNotEmpty) {
      // Puedes obtener la primera ubicación filtrada y centrar el mapa en ella
      final currentFilteredLocations = ref.read(filteredLocationsProvider);
      if (currentFilteredLocations.isNotEmpty) {
        final firstLocation = currentFilteredLocations.first;
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(firstLocation.latitude, firstLocation.longitude),
          ),
        );
        // SnackBar opcional para confirmar la búsqueda/centrado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Centrando en: ${firstLocation.name}')),
          );
        }
      } else {
        // SnackBar si no se encontraron resultados
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron ubicaciones con esa búsqueda'),
            ),
          );
        }
      }
    } else {
      // SnackBar si la búsqueda está vacía
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa un texto para buscar'),
          ),
        );
      }
    }
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

    // Crear los marcadores a partir de las ubicaciones filtradas
    Set<Marker> markers = {};
    if (locationsState is LocationsLoaded) {
      // Solo creamos marcadores si están cargadas
      final zoom = _zoomNotifier.value;
      final currentLayer = _getLayerForZoom(zoom);

      markers =
          filteredLocations
              .where((location) => location.layer <= currentLayer)
              .map(
                (location) => Marker(
                  markerId: MarkerId(location.id),
                  position: LatLng(location.latitude, location.longitude),
                  infoWindow: InfoWindow(
                    title: location.name,
                    snippet: location.address ?? location.description,
                  ),
                ),
              )
              .toSet();
    }
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
                          Theme.of(context).colorScheme.surfaceVariant,
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
                  final markers = <Marker>{};
                  print('🔍 Renderizando capa $currentLayer');
                  for (var l in filteredLocations) {
                    print('POI: ${l.name} - capa ${l.layer}');
                  }

                  if (locationsState is LocationsLoaded) {
                    markers.addAll(
                      filteredLocations
                          .where((location) => location.layer <= currentLayer)
                          .map(
                            (location) => Marker(
                              markerId: MarkerId(location.id),
                              position: LatLng(
                                location.latitude,
                                location.longitude,
                              ),
                              infoWindow: InfoWindow(
                                title: location.name,
                                snippet:
                                    location.address ?? location.description,
                              ),
                            ),
                          ),
                    );
                  }

                  return Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: _initialPosition,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        markers: markers,
                        onCameraMove: (position) {
                          _zoomNotifier.value = position.zoom;
                        },
                        onCameraIdle: () async {
                          final z = await _mapController?.getZoomLevel();
                          if (z != null) _zoomNotifier.value = z;
                        },
                      ),

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
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Zoom: ${zoom.toStringAsFixed(1)} | Capa $currentLayer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _searchLocation,
        child: const Icon(Icons.location_searching),
        tooltip: 'Buscar ubicación actual',
      ),
    );
  }
}
