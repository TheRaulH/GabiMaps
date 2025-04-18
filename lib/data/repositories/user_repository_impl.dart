import 'dart:async';

import 'package:gabimaps/data/models/user_model.dart';
import 'package:gabimaps/domain/entities/user.dart';
import 'package:gabimaps/domain/repositories/user_repository.dart';
import 'package:gabimaps/services/firestore_service.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreService _firestoreService;

  UserRepositoryImpl(this._firestoreService);

  @override
  Future<User?> getUser(String uid) async {
    final userData = await _firestoreService.getDocument(
      'users',
      uid.toString(),
    );
    if (userData != null) {
      return Future.value(
        UserModel.fromFirestore(userData, uid) as User,
      ); // Retorna un Future<User?>
    } else {
      return Future.value(null); // Retorna un Future<User?>
    }
  }

  @override
  Future<void> saveUser(User user) async {
    await _firestoreService.setDocument(
      'users',
      user.uid.toString(),
      (user as UserModel).toFirestore(),
    );
  }
}
