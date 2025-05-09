import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import '../data/user_repository.dart';
import '../data/user_model.dart';

// Provider para la instancia de UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
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
