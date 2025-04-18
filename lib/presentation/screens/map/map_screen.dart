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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
      markers =
          filteredLocations.map((location) {
            return Marker(
              markerId: MarkerId(location.id),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(
                title: location.name,
                snippet: location.address ?? location.description,
                // Puedes agregar un onTap a InfoWindow si quieres navegar o mostrar detalles
                // onTap: () { _showLocationDetails(context, location); } // Si tienes esta función
              ),
              // Opcional: personalizar el icono del marcador basado en la categoría
              // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            );
          }).toSet();
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
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: _initialPosition,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                    markers: markers, // Asigna el conjunto de marcadores
                  ),
                  // Mostrar un indicador de carga si el estado es loading
                  if (locationsState is LocationsLoading)
                    const Center(child: CircularProgressIndicator()),
                  // Mostrar un mensaje de error si el estado es error
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
                  // Mostrar un mensaje si no hay ubicaciones cargadas y no hay error/carga
                  if (locationsState is LocationsLoaded &&
                      filteredLocations.isEmpty &&
                      _searchController.text.isNotEmpty)
                    const Center(
                      child: Text(
                        'No se encontraron ubicaciones con esos filtros',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                ],
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
