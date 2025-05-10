import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';



class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;


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

  //Actualizar foto de perfil
  Future<void> updateProfileImage(String uid, String imageUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'photoURL': imageUrl,
    });
  }

  Future<String> uploadProfileImage(String uid, String filePath) async {
    try {
      print('Subiendo imagen de perfil para el usuario: $uid');
      print('Ruta del archivo: $filePath');
      final ref = _storage.ref('profile_images/$uid');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
      throw Exception('Error al subir la imagen: ${e.message}');
    } catch (e) {
      debugPrint('Upload Error: $e');
      throw Exception('Error inesperado al subir la imagen');
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
