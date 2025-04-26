import 'dart:ui' as ui; // Importa dart:ui con un alias

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/presentation/providers/location_provider.dart';
import 'package:gabimaps/presentation/screens/settings/settings_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  double _currentZoom = 14.0;
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

  BitmapDescriptor?
  _customIcon; // Variable para almacenar el icono personalizado


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

    // Cargar el icono personalizado al inicializar
    _loadCustomMarkerIcon();

    // Escucha los cambios en el controlador de búsqueda para actualizar el provider
    _searchController.addListener(_onSearchChanged);
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

    final cameraUpdate = CameraUpdate.newLatLng(
      LatLng(position.latitude, position.longitude),
    );

    _mapController?.animateCamera(cameraUpdate);
  }

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

     
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _currentZoom = position.zoom;
    });
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
                              // Centrar mapa en esta ubicación y cerrar modal
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(location.latitude, location.longitude),
                                  18.0,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.center_focus_strong),
                            label: const Text('Centrar en mapa'),
                          ),
                          // Botón para compartir ubicación
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

  // Métodos para los controles del mapa
  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _resetToInitialPosition() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        _initialPosition.target,
        _initialPosition.zoom,
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

    // Crear los marcadores a partir de las ubicaciones filtradas
    Set<Marker> markers = {};
    if (locationsState is LocationsLoaded && _customIcon != null) {
      // Solo creamos marcadores si están cargadas
      final zoom = _zoomNotifier.value;
      final currentLayer = _getLayerForZoom(zoom);

      markers =
          filteredLocations.map((location) {
            return Marker(
              markerId: MarkerId(location.id),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(
                title: location.name,
                snippet: location.address ?? location.description,
                // Al hacer tap en la ventana de información, mostrar detalles completos
                onTap: () => _showLocationDetails(context, location),
              ),
              // También podemos hacer que al hacer clic en el marcador muestre los detalles directamente
              onTap: () {
                // Usa el icono predeterminado si el personalizado aún no está cargado
                _showLocationDetails(context, location);
              },
              icon: _customIcon!, // Asigna el icono personalizado aquí
              // Opcional: personalizar el icono del marcador basado en la categoría
              // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            );
          }).toSet();
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
                    onCameraMove: _onCameraMove, // Añade este callback
                  ),
                  // Controles personalizados del mapa
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      children: [
                        // Botón de zoom in
                        FloatingActionButton.small(
                          heroTag: 'zoomIn',
                          onPressed: _zoomIn,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(height: 8),
                        // Botón de zoom out
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

                        // Botón de centrar
                      ],
                    ),
                  ),

                  // Indicador de coordenadas (opcional)
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
       
    );
  }
}
