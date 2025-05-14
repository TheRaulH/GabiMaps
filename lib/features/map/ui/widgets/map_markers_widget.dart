import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/home/widgets/category_marker_icon.dart';
import 'package:gabimaps/features/map/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';

class MapMarkersWidget extends ConsumerWidget {
  final double currentZoom;
  final ValueNotifier<double> zoomNotifier;
  final Function(BuildContext context, dynamic location) onMarkerTap;
  final double minZoomForMarkers;
  final double maxZoomForMarkers;
  final double baseMarkerSize;
  final bool showMarkers;

  const MapMarkersWidget({
    super.key,
    required this.currentZoom,
    required this.zoomNotifier,
    required this.onMarkerTap,
    this.minZoomForMarkers = 13.0,
    this.maxZoomForMarkers = 18.0,
    this.baseMarkerSize = 40.0,
    this.showMarkers = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showMarkers) return const SizedBox.shrink();

    final locationsState = ref.watch(locationsProvider);
    final filteredLocations = ref.watch(filteredLocationsProvider);
    final selectedFilters = ref.watch(selectedCategoriesProvider);

    if (locationsState is! LocationsLoaded) {
      return const SizedBox.shrink();
    }

    final zoom = zoomNotifier.value;
    final currentLayer = _getLayerForZoom(zoom);
    final hasCategoryFilter = selectedFilters.isNotEmpty;

    final markers =
        filteredLocations
            .where(
              (location) => _shouldShowLocation(
                location,
                currentLayer,
                hasCategoryFilter,
                selectedFilters,
              ),
            )
            .map((location) => _buildMarker(context, location))
            .toList();

    return MarkerLayer(markers: markers);
  }

  bool _shouldShowLocation(
    dynamic location,
    int currentLayer,
    bool hasCategoryFilter,
    Set<String> selectedFilters,
  ) {
    if (hasCategoryFilter) {
      return location.categories?.any(selectedFilters.contains) ?? false;
    } else {
      return location.layer == 1 || location.layer <= currentLayer;
    }
  }

  Marker _buildMarker(BuildContext context, dynamic location) {
    final markerSize = _calculateMarkerSize();
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: markerSize,
      height: markerSize,
      child: GestureDetector(
        onTap: () => onMarkerTap(context, location),
        child: CategoryMarkerIcon(
          category: location.categories?.first ?? 'default',
          size: markerSize,
        ),
      ),
    );
  }

  double _calculateMarkerSize() {
    return (currentZoom.clamp(minZoomForMarkers, maxZoomForMarkers) - 10) *
        (baseMarkerSize / 8);
  }

  int _getLayerForZoom(double zoom) {
    if (zoom <= 16) return 0;
    if (zoom < 18) return 1;
    return 2;
  }
}
