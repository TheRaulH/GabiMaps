import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/map/providers/location_provider.dart';
import 'package:gabimaps/features/map/ui/widgets/location_details_widget.dart';
import 'package:gabimaps/features/map/ui/widgets/map_controls_widget.dart';
import 'package:gabimaps/features/map/ui/widgets/map_markers_widget.dart';
import 'package:gabimaps/features/map/ui/widgets/search_filter_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:gabimaps/features/map/providers/cache_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Mantiene el estado vivo
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Map state
  StreamSubscription<MapEvent>? _mapEventSubscription;
  final ValueNotifier<double> _zoomNotifier = ValueNotifier(14.0);
  LatLng? _currentPosition;
  double _currentZoom = 17.0;
  //bool _trackingLocation = false; // Nuevo estado para seguimiento
  //late StreamController<Position> _positionStreamController;
  //StreamSubscription<Position>? _positionSubscription;

  late Stream<Position> _locationStream; // Stream para la ubicación actual

  Timer? _debounce;

  static const minLat = -17.779817462275247;
  static const maxLat = -17.772732948991735;
  static const minLng = -63.198970197924325;
  static const maxLng = -63.19011474035158;

  // Constants
  static const LatLng _initialPosition = LatLng(
    -17.77523823913366,
    -63.195728548113955,
  );

  static const Map<String, LatLng> _predefinedLocations = {
    'Campus Central': LatLng(-17.775672, -63.197941),
    'Dormitorios': LatLng(-17.774300, -63.209315),
    'Campus Norte': LatLng(-17.769092, -63.191998),
  };

  @override
  void initState() {
    super.initState();

    _initializeData();
    _setupListeners();

    _locationStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10, // Actualiza cada 10 metros
          ),
        ).asBroadcastStream();
  }

  void _initializeData() {
    Future.microtask(() {
      final locationsState = ref.read(locationsProvider);
      if (locationsState is! LocationsLoaded &&
          locationsState is! LocationsLoading) {
        ref.read(locationsProvider.notifier).loadLocations();
      }
    });
  }

  void _setupListeners() {
    _searchController.addListener(_onSearchChanged);
    _mapEventSubscription = _mapController.mapEventStream.listen(_onMapEvent);
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMove || event is MapEventMoveEnd) {
      final center = _mapController.camera.center;
      final zoom = _mapController.camera.zoom;
      setState(() {
        _currentPosition = LatLng(center.latitude, center.longitude);
        _currentZoom = zoom;
        _zoomNotifier.value = zoom;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // do something with query
      ref.read(locationSearchProvider.notifier).state = _searchController.text;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorMessage('Los servicios de ubicación están desactivados.');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorMessage('Los permisos de ubicación fueron denegados.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorMessage(
          'Los permisos de ubicación están denegados permanentemente.',
        );
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lng = position.longitude;

      // Check if within bounds
      if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(lat, lng);
          });
          _mapController.move(_currentPosition!, _currentZoom);
        }
      } else {
        _showErrorMessage('No estas en la gabi.');
      }
    } catch (e) {
      _showErrorMessage('Error al obtener la ubicación: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _zoomIn() => _updateZoom(_currentZoom + 0.5);

  void _zoomOut() => _updateZoom(_currentZoom - 0.5);

  void _updateZoom(double newZoom) {
    final clampedZoom = newZoom.clamp(3.0, 20.0);
    _mapController.move(_mapController.camera.center, clampedZoom);
  }

  void _searchLocation(String text) {
    final searchText = _searchController.text;
    if (searchText.isEmpty) {
      _showErrorMessage('Por favor, ingresa un texto para buscar');
      return;
    }

    final filteredLocations = ref.read(filteredLocationsProvider);
    if (filteredLocations.isEmpty) {
      _showErrorMessage('No se encontraron ubicaciones con esa búsqueda');
      return;
    }

    final firstLocation = filteredLocations.first;
    _mapController.move(
      LatLng(firstLocation.latitude, firstLocation.longitude),
      _currentZoom,
    );

    _showErrorMessage('Centrando en: ${firstLocation.name}');
  }

  void _showLocationDetails(BuildContext context, location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => LocationDetailsWidget(
            location: location,
            mapController: _mapController,
          ),
    );
  }

  void _toggleFilter(String filter) {
    final selectedFiltersNotifier = ref.read(
      selectedCategoriesProvider.notifier,
    );
    final currentFilters = Set<String>.from(selectedFiltersNotifier.state);

    setState(() {
      if (currentFilters.contains(filter)) {
        currentFilters.remove(filter);
      } else {
        currentFilters.add(filter);
      }
      selectedFiltersNotifier.state = currentFilters;
    });
  }

  void _showLocationSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar punto de inicio'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _predefinedLocations.entries
                      .map(
                        (entry) => ListTile(
                          title: Text(entry.key),
                          onTap: () {
                            _mapController.move(entry.value, 17.0);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  Widget _buildMapView() {
    return ValueListenableBuilder<double>(
      valueListenable: _zoomNotifier,
      builder: (context, zoom, _) {
        final locationsState = ref.watch(locationsProvider);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                keepAlive: true,
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                  flags: ~InteractiveFlag.rotate,
                ),
                initialCenter: /*_currentPosition ??*/ _initialPosition,
                initialZoom: _currentZoom,
                minZoom: 17,
                maxZoom: 20,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(minLat, minLng), // suroeste (minLat, minLng)
                    const LatLng(maxLat, maxLng), // noreste (maxLat, maxLng)
                  ),
                ),
                /*  onPositionChanged: (position, hasGesture) {
                  if (mounted) {
                    _currentPosition = position.center;
                    _currentZoom = position.zoom;
                    _zoomNotifier.value = _currentZoom;
                  }
                },*/
              ),

              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final asyncStore = ref.watch(tileCacheProvider);
                    return asyncStore.when(
                      data: (store) {
                        return isDarkMode
                            ? TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              tileProvider: CachedTileProvider(
                                store: store,
                                maxStale: const Duration(days: 365),
                              ),
                              tileBuilder: _darkModeTileBuilder,
                              userAgentPackageName: 'com.example.app',
                            )
                            : TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              tileProvider: CachedTileProvider(
                                store: store,
                                maxStale: const Duration(days: 365),
                              ),
                              userAgentPackageName: 'com.example.app',
                            );
                      },
                      loading:
                          () =>
                              const SizedBox(), // o CircularProgressIndicator()
                      error:
                          (err, _) => Center(
                            child: Text('Error al cargar caché: $err'),
                          ),
                    );
                  },
                ),
                /*  
                Para dibujar el area especifica de la gabriel
                   PolygonLayer(
                  polygons: [
                    Polygon(
                      points: [
                        LatLng(minLat, minLng), // Suroeste
                        LatLng(minLat, maxLng), // Sureste
                        LatLng(maxLat, maxLng), // Noreste
                        LatLng(maxLat, minLng), // Noroeste
                      ],
                      color: Colors.blue.withOpacity(0.2),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blueAccent,
                    ),
                  ],
                ), */

                // Capa base (siempre presente)

                // TileLayer(
                //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                //   userAgentPackageName: 'com.example.app',
                // ),

                // // Capa oscura (solo visible en modo oscuro)
                // TileLayer(
                //   urlTemplate:
                //       'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                //   subdomains: const ['a', 'b', 'c'],
                //   userAgentPackageName: 'com.example.app',
                // ),
                // Marcador de ubicación actual
                if (_currentPosition != null)
                  CurrentLocationLayer(
                    positionStream: _locationStream.map((position) {
                      return LocationMarkerPosition(
                        latitude: position.latitude,
                        longitude: position.longitude,
                        accuracy: position.accuracy,
                      );
                    }),
                    style: LocationMarkerStyle(
                      marker: const DefaultLocationMarker(
                        color: Colors.indigo,
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      markerSize: const Size(40, 40),
                      accuracyCircleColor: Colors.blue.withOpacity(0.2),
                      showAccuracyCircle: true,
                    ),
                    alignPositionOnUpdate:
                        AlignOnUpdate
                            .never, // debe estar en never para que no mueva el mapa al iniciar la app
                  ),

                MapMarkersWidget(
                  currentZoom: _currentZoom,
                  zoomNotifier: _zoomNotifier,
                  onMarkerTap: _showLocationDetails,
                  minZoomForMarkers: 12.0,
                  maxZoomForMarkers: 19.0,
                  baseMarkerSize: 48.0,
                  showMarkers: true,
                ),
              ],
            ),

            // Map controls
            MapControlsWidget(
              mapController: _mapController,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onCurrentLocation: _getCurrentLocation,
              currentPosition: _currentPosition,
              currentZoom: _currentZoom,
            ),

            // Status overlays
            _buildStatusOverlays(locationsState),
          ],
        );
      },
    );
  }

  Widget _darkModeTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
        0, 0, 0, 1, 0, // Alpha channel
      ]),
      child: tileWidget,
    );
  }

  Widget _buildStatusOverlays(dynamic locationsState) {
    if (locationsState is LocationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (locationsState is LocationsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error al cargar ubicaciones: ${locationsState.message}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    final filteredLocations = ref.watch(filteredLocationsProvider);
    if (locationsState is LocationsLoaded &&
        filteredLocations.isEmpty &&
        _searchController.text.isNotEmpty) {
      return const Center(
        child: Text(
          'No se encontraron ubicaciones con esos filtros',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Importante: llamar a super.build

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Mapa como capa base (fondo)
            _buildMapView(),

            // SearchAndFilterWidget superpuesto en la parte superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SearchAndFilterWidget(
                searchController: _searchController,
                onSearchChanged: (value) {
                  ref.read(locationSearchProvider.notifier).state = value;
                },
                onFilterToggled: _toggleFilter,
                onSearchSubmitted:
                    () => _searchLocation(_searchController.text),
                onMenuPressed: _showLocationSelectionDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _mapEventSubscription?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    _zoomNotifier.dispose();
    _debounce?.cancel();

    super.dispose();
  }
}
