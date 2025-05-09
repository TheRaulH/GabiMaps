import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabimaps/features/user/data/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Crear un nuevo usuario en Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
            user.toFirestore(),
            SetOptions(
              merge: true,
            ), // Merge para no sobrescribir datos existentes
          );
    } catch (e) {
      throw Exception('Error al crear usuario: ${e.toString()}');
    }
  }

  // Obtener un usuario por su UID
  Future<UserModel> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw Exception('Usuario no encontrado');
      }
      return UserModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error al obtener usuario: ${e.toString()}');
    }
  }

  // Verificar si un usuario existe en Firestore
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error al verificar usuario: ${e.toString()}');
    }
  }

  // Actualizar datos del usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar usuario: ${e.toString()}');
    }
  }

  // Stream de cambios en el usuario
  Stream<UserModel> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) => UserModel.fromFirestore(snapshot.data()!, snapshot.id),
        );
  }
}
