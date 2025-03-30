import '../../domain/entities/location.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? address,
  }) : super(
         id: id,
         name: name,
         latitude: latitude,
         longitude: longitude,
         address: address,
       );

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
