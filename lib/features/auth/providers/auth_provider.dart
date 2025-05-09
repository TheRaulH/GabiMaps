import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/shared/services/firestore_service.dart';
import '../data/auth_service.dart';

// 🔸 Utilidad para extraer nombre de email
String quitarArroba(String email) => email.split('@')[0];

// 🔹 Provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<User?> {
  final Ref ref;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late final StreamSubscription<User?> _authSubscription;

  AuthNotifier(this.ref) : super(FirebaseAuth.instance.currentUser) {
    // 🔁 Escuchar cambios de sesión en tiempo real
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
    });
  }

  // 🔹 Registro con email
  Future<void> register(String email, String password) async {
    try {
      final firebaseUser = await _authService.registerWithEmail(
        email,
        password,
      );
      if (firebaseUser == null) return;

      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: email,
        rol: 'user',
        nombre: quitarArroba(email),
      );

      await _firestoreService.setDocument(
        'users',
        firebaseUser.uid,
        newUser.toFirestore(),
      );
    } catch (e) {
      print('❌ Error en registro: $e');
    }
  }

  // 🔹 Login con email
  Future<void> login(String email, String password) async {
    try {
      await _authService.loginWithEmail(email, password);
      // No necesitas llamar a updateUser, authStateChanges() lo maneja
    } catch (e) {
      print('❌ Error en login: $e');
    }
  }

  // 🔹 Login con Google
  Future<void> loginWithGoogle() async {
    try {
      final firebaseUser = await _authService.signInWithGoogle();
      if (firebaseUser == null) return;

      final exists = await _firestoreService.getDocument(
        'users',
        firebaseUser.uid,
      );

      if (exists == null) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          rol: 'user',
          nombre:
              firebaseUser.displayName ??
              quitarArroba(firebaseUser.email ?? ''),
          photoURL: firebaseUser.photoURL,
        );

        await _firestoreService.setDocument(
          'users',
          firebaseUser.uid,
          newUser.toFirestore(),
        );
      }
    } catch (e) {
      print('❌ Error en login con Google: $e');
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    await _authService.signOut();
    // authStateChanges emitirá null automáticamente
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
