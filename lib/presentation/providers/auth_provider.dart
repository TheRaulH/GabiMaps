import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:gabimaps/data/models/user_model.dart';
import 'package:gabimaps/services/firestore_service.dart';
import '../../services/auth_service.dart';

//funcion para quitar el @gmail del email
String quitarArroba(String email) {
  // Dividir el email por '@' y tomar la primera parte
  String nombreUsuario = email.split('@')[0];
  return nombreUsuario;
}

// 🔹 Proveedor de estado del usuario autenticado
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();


  AuthNotifier() : super(FirebaseAuth.instance.currentUser);

  // 🔹 Actualizar usuario cuando haya cambios en FirebaseAuth
  void updateUser(User? user) {
    state = user;
  }

  // 🔹 Registro con email
  Future<void> register(String email, String password) async {
    try {
      User? firebaseUser = await _authService.registerWithEmail(
        email,
        password,
      );
      if (firebaseUser != null) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: email,
          rol: 'user',
          //nombre sera el nombre de usuario que se obtiene del email
          nombre: quitarArroba(email),
        );

        await _firestoreService.setDocument(
          'users',
          firebaseUser.uid,
          newUser.toFirestore(),
        );
        updateUser(firebaseUser);
      } else {
        print('Error al registrar el usuario: $firebaseUser');
        return;
      }

      updateUser(firebaseUser);
    } catch (e) {
      print('Error en registro: $e');
      return;
    }

     
  }

  // 🔹 Login con email
  Future<void> login(String email, String password) async {
    User? user = await _authService.loginWithEmail(email, password);
    updateUser(user);
  }

  // 🔹 Login con Google
  Future<void> loginWithGoogle() async {
    try {
      User? firebaseUser = await _authService.signInWithGoogle();
      if (firebaseUser != null) {
        // Verificar si el usuario ya existe en Firestore
        final userDoc = await _firestoreService.getDocument(
          'users',
          firebaseUser.uid,
        );

        if (userDoc == null) {
          // El usuario es nuevo o no tiene un documento en Firestore, crear uno
          final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            rol: 'user',
            nombre: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
          );

          await _firestoreService.setDocument(
            'users',
            firebaseUser.uid,
            newUser.toFirestore(),
          );
          updateUser(
            firebaseUser,
          ); // Podrías actualizar con el UserModel si lo prefieres
        } else {
          // El usuario ya existe en Firestore
          updateUser(
            firebaseUser,
          ); // O podrías cargar el UserModel desde Firestore aquí si lo necesitas inmediatamente
        }
      } else {
        // Hubo un error al iniciar sesión con Google
        print('Error al iniciar sesión con Google');
        return;
      }
    } catch (e) {
      print('Error en login con Google: $e');
      return;
    }
  }

   

  // 🔹 Logout
  Future<void> logout() async {
    await _authService.signOut();
    //ir a la ruta de login

    // Limpiar el estado del usuario en Riverpod
    updateUser(null);
  }
}
