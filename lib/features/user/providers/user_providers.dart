import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import 'package:gabimaps/features/user/data/users_repository.dart';
import 'package:gabimaps/features/user/providers/users_providers.dart'; 
import '../data/user_repository.dart';
import '../data/user_model.dart';

// Provider para la instancia de UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

// Provider para el usuario actual (UserModel)
final userModelProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  // Obtener el UID del usuario autenticado
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null) {
    // Si no hay usuario autenticado, retornar null
    return Stream.value(null);
  }

  // Obtener el UserRepository
  final userRepository = ref.watch(userRepositoryProvider);

  // Retornar stream de cambios del usuario
  return userRepository.userStream(authUser.uid).handleError((error) {
    // Puedes manejar errores específicos aquí
    throw error;
  });
});

// Familia de providers para operaciones de usuario
final userOperationProvider = Provider.family<UserOperation, UserOperationType>(
  (ref, operationType) {
    final userRepository = ref.watch(userRepositoryProvider);
    return UserOperation(userRepository, operationType);
  },
);

// Clase auxiliar para operaciones de usuario
class UserOperation {
  final UserRepository _repository;
  final UserOperationType type;

  UserOperation(this._repository, this.type);

  Future<Object> execute({UserModel? user, String? uid}) async {
    switch (type) {
      case UserOperationType.createUser:
        if (user == null) throw ArgumentError('User is required');
        await _repository.createUser(user);
        return user;
      case UserOperationType.getUser:
        if (uid == null) throw ArgumentError('UID is required');
        return await _repository.getUser(uid);
      case UserOperationType.userExists:
        if (uid == null) throw ArgumentError('UID is required');
        return await _repository.userExists(uid);
      case UserOperationType.updateUser:
        if (user == null) throw ArgumentError('User is required');
        await _repository.updateUser(user);
 
        return user;     
      
    }
  }
}

// Tipos de operaciones de usuario
enum UserOperationType { createUser, getUser, userExists, updateUser }

// Nuevos providers para operaciones administrativas
final userAdminOperationProvider =
    Provider.family<UserAdminOperation, UserAdminOperationType>((
      ref,
      operationType,
    ) {
      final usersRepository = ref.watch(usersRepositoryProvider);
      return UserAdminOperation(usersRepository, operationType);
    });

class UserAdminOperation {
  final UsersRepository _repository;
  final UserAdminOperationType type;

  UserAdminOperation(this._repository, this.type);

  Future<Object?> execute({String? uid, String? role, bool? isActive}) async {
    switch (type) {
      case UserAdminOperationType.updateRole:
        if (uid == null || role == null) {
          throw ArgumentError('UID and role are required');
        }
        await _repository.updateUserRole(uid, role);
        return true;
      case UserAdminOperationType.searchUsers:
        if (uid == null) {
          throw ArgumentError('Query is required');
        }
        return await _repository.searchUsers(uid);
      case UserAdminOperationType.updateStatus:
        if (uid == null || isActive == null) {
          throw ArgumentError('UID is required');
        }
        await _repository.updateUserStatusFirestore(uid, isActive);
        return true;
    }
  }
}

enum UserAdminOperationType { updateRole, searchUsers, updateStatus }
