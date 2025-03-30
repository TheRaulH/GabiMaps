import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetNearbyLocations {
  final LocationRepository repository;

  GetNearbyLocations(this.repository);

  Future<List<LocationEntity>> call(double latitude, double longitude) {
    return repository.getNearbyLocations(latitude, longitude);
  }
}

class SaveLocation {
  final LocationRepository repository;

  SaveLocation(this.repository);

  Future<void> call(LocationEntity location) {
    return repository.saveLocation(location);
  }
}

class LocationUseCases {
  final GetNearbyLocations getNearbyLocations;
  final SaveLocation saveLocation;

  LocationUseCases({
    required this.getNearbyLocations,
    required this.saveLocation,
  });
}
