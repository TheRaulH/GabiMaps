import '../entities/location.dart';

abstract class LocationRepository {
  Future<List<LocationEntity>> getNearbyLocations(
    double latitude,
    double longitude,
  );
  Future<void> saveLocation(LocationEntity location);
}
