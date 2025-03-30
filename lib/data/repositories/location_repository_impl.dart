import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final FirebaseFirestore _firestore;

  // 🔹 **Corrección: Constructor que recibe Firestore**
  LocationRepositoryImpl(this._firestore);

  @override
  Future<List<LocationEntity>> getNearbyLocations(
    double latitude,
    double longitude,
  ) async {
    final snapshot = await _firestore.collection('locations').get();
    return snapshot.docs
        .map((doc) => LocationModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> saveLocation(LocationEntity location) async {
    await _firestore
        .collection('locations')
        .doc(location.id)
        .set(
          LocationModel(
            id: location.id,
            name: location.name,
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.address,
          ).toMap(),
        );
  }
}
