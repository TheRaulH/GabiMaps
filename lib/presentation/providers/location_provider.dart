// location_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:gabimaps/domain/entities/location.dart'; // Asegúrate de tener la ruta correcta a tu entidad

// Estados del provider
abstract class LocationsState {}

class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<Location> locations;
  LocationsLoaded(this.locations);
}

class LocationsError extends LocationsState {
  final String message;
  LocationsError(this.message);
}

// Notifier
class LocationsNotifier extends StateNotifier<LocationsState> {
  final FirebaseFirestore _firestore;

  LocationsNotifier({required FirebaseFirestore firestore})
    : _firestore = firestore,
      super(LocationsInitial()) {
    loadLocations();
  }

  Future<void> loadLocations() async {
    try {
      state = LocationsLoading();

      final snapshot =
          await _firestore.collection('locations').orderBy('name').get();

      final locations =
          snapshot.docs
              .map((doc) => Location.fromMap(doc.data(), doc.id))
              .toList();

      state = LocationsLoaded(locations);
    } catch (e) {
      state = LocationsError('Error al cargar ubicaciones: $e');
    }
  }

  Future<String> addLocation(Location location) async {
    try {
      final docRef = await _firestore
          .collection('locations')
          .add(location.toMap());
      await loadLocations(); // Recargar la lista
      return docRef.id;
    } catch (e) {
      state = LocationsError('Error al agregar ubicación: $e');
      throw e;
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
      await _firestore
          .collection('locations')
          .doc(location.id)
          .update(location.toMap());

      await loadLocations(); // Recargar la lista
    } catch (e) {
      state = LocationsError('Error al actualizar ubicación: $e');
      throw e;
    }
  }

  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore.collection('locations').doc(locationId).delete();

      await loadLocations(); // Recargar la lista
    } catch (e) {
      state = LocationsError('Error al eliminar ubicación: $e');
      throw e;
    }
  }

  Future<List<Location>> searchLocations(String query) async {
    if (state is LocationsLoaded) {
      final locations = (state as LocationsLoaded).locations;
      return locations
          .where(
            (location) =>
                location.name.toLowerCase().contains(query.toLowerCase()) ||
                (location.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false) ||
                (location.address?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }
    return [];
  }
}

// Providers
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final locationsProvider =
    StateNotifierProvider<LocationsNotifier, LocationsState>((ref) {
      return LocationsNotifier(firestore: ref.watch(firebaseFirestoreProvider));
    });

// Provider para una ubicación específica
final locationProvider = Provider.family<Location?, String>((ref, locationId) {
  final state = ref.watch(locationsProvider);
  if (state is LocationsLoaded) {
    try {
      return state.locations.firstWhere(
        (location) => location.id == locationId,
      );
    } catch (e) {
      return null;
    }
  }
  return null;
});

// Provider para la búsqueda de ubicaciones
final locationSearchProvider = StateProvider<String>((ref) => '');

// Provider para los filtros de categoría seleccionados
final selectedCategoriesProvider = StateProvider<Set<String>>((ref) => {});

// Modifica filteredLocationsProvider para incluir el filtro de categorías
final filteredLocationsProvider = Provider<List<Location>>((ref) {
  final locationsState = ref.watch(
    locationsProvider,
  ); // Observa el estado de carga principal
  final searchQuery = ref.watch(locationSearchProvider);
  final selectedCategories = ref.watch(
    selectedCategoriesProvider,
  ); // Observa los filtros seleccionados

  // Solo filtramos si las ubicaciones se han cargado exitosamente
  if (locationsState is LocationsLoaded) {
    // Aplicar filtro de búsqueda
    final searchFiltered =
        locationsState.locations
            .where(
              (location) =>
                  location.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  (location.description?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false) ||
                  (location.address?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();

    // Si no hay categorías seleccionadas, devolver solo el resultado de la búsqueda
    if (selectedCategories.isEmpty) {
      return searchFiltered;
    }

    // Aplicar filtro de categoría a los resultados de la búsqueda
    return searchFiltered.where((location) {
      // Si la ubicación no tiene categorías, no coincide con ningún filtro seleccionado
      if (location.categories == null || location.categories!.isEmpty) {
        return false;
      }
      // La ubicación coincide si tiene AL MENOS UNA de las categorías seleccionadas
      return location.categories!.any(
        (category) => selectedCategories.contains(category),
      );
    }).toList();
  }

  // Si el estado no es LocationsLoaded (cargando, error, etc.), devolvemos lista vacía
  return [];
});
