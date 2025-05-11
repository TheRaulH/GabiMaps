import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

// Provider para la instancia de AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// StreamProvider para los cambios de estado de autenticación
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Provider para el usuario actual (sincrónico)
final currentUserProvider = Provider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

// Familia de providers para operaciones de autenticación
final authOperationProvider = Provider.family<AuthOperation, AuthOperationType>(
  (ref, operationType) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthOperation(authRepository, operationType);
  },
);

// Clase auxiliar para operaciones de autenticación
class AuthOperation {
  final AuthRepository _repository;
  final AuthOperationType type;

  AuthOperation(this._repository, this.type);

  Future<User?> execute({String? email, String? password}) async {
    switch (type) {
      case AuthOperationType.signInWithEmail:
        if (email == null || password == null) {
          throw ArgumentError('Email and password are required');
        }
        final userModel = await _repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('UserModel: $userModel');
        return _repository.currentUser;
      case AuthOperationType.signInWithGoogle:
        final userModel = await _repository.signInWithGoogle();
        debugPrint('UserModel: $userModel');
        return _repository.currentUser;
      case AuthOperationType.signOut:
        await _repository.signOut();
        return null;
      case AuthOperationType.passwordReset:
        if (email == null) {
          throw ArgumentError('Email is required');
        }
        await _repository.sendPasswordReset(email: email);
        return null;

      case AuthOperationType.registerWithEmail:
        if (email == null || password == null) {
          throw ArgumentError('Email and password are required');
        }
        final userModel = await _repository.registerWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('UserModel: $userModel');
        return _repository.currentUser;
    }
  }
}

// Tipos de operaciones de autenticación
enum AuthOperationType {
  signInWithEmail,
  signInWithGoogle,
  signOut,
  passwordReset,
  registerWithEmail,
}
