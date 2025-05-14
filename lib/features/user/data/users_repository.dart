import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gabimaps/features/user/data/user_model.dart';

class UsersRepository {
  final FirebaseFirestore _firestore;

  UsersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Obtener stream de todos los usuarios
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener usuarios filtrados por rol
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('rol', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Obtener usuarios paginados
  Future<List<UserModel>> getUsersPaginated({
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('users')
        .orderBy('fechaRegistro')
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Buscar usuarios por nombre o email
  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('nombre', isGreaterThanOrEqualTo: query)
            .where('nombre', isLessThan: '${query}z')
            .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Actualizar rol de usuario
  Future<void> updateUserRole(String uid, String newRole) async {
    await _firestore.collection('users').doc(uid).update({'rol': newRole});
  }
  // Método para actualizar el estado activo/inactivo en Firestore
  Future<void> updateUserStatusFirestore(String uid, bool isActive) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': isActive,
      });
      debugPrint('Estado de usuario actualizado a $isActive para UID: $uid');
    } catch (e) {
      throw Exception(
        'Error al actualizar el estado de usuario en Firestore para UID $uid: ${e.toString()}',
      );
    }
  }
}
