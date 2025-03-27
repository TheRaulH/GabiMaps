import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

// 🔹 Proveedor de estado del usuario autenticado
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(FirebaseAuth.instance.currentUser);

  // 🔹 Actualizar usuario cuando haya cambios en FirebaseAuth
  void updateUser(User? user) {
    state = user;
  }

  // 🔹 Registro con email
  Future<void> register(String email, String password) async {
    User? user = await _authService.registerWithEmail(email, password);
    updateUser(user);
  }

  // 🔹 Login con email
  Future<void> login(String email, String password) async {
    User? user = await _authService.loginWithEmail(email, password);
    updateUser(user);
  }

  // 🔹 Login con Google
  Future<void> loginWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    updateUser(user);
  }

  // 🔹 Logout
  Future<void> logout() async {
    await _authService.signOut();
    updateUser(null);
  }
}
