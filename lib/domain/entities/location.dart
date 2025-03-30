class LocationEntity {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  LocationEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
