import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart'; 

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // Constructor con dependencias inyectadas
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Obtener el usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Flujo de cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Iniciar sesión con email y contraseña
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener datos adicionales del usuario desde Firestore
      return await _getUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Iniciar sesión con Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Iniciar el flujo de autenticación con Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticar con Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Verificar si es un nuevo usuario
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Crear documento en Firestore para el nuevo usuario
        await _createUserInFirestore(userCredential.user!);
      }

      // Obtener datos del usuario
      return await _getUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error during Google sign in: ${e.toString()}');
    }
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento en Firestore
      await _createUserInFirestore(userCredential.user!);

      return await _getUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }


  // Enviar correo de recuperación de contraseña
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  // Métodos privados de ayuda

  // Crear usuario en Firestore
  Future<void> _createUserInFirestore(User user) async {
    //agregar el nombre del email antes de @ como nombre del usermodel
    final emailParts = user.email?.split('@');

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      rol: 'user', // Rol por defecto
      nombre: user.displayName?.split(' ').first ?? emailParts?.first ?? '',
      apellido: user.displayName?.split(' ').last,
      photoURL: user.photoURL,
      fechaRegistro: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  // Obtener datos del usuario desde Firestore
  Future<UserModel> _getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User data not found');
    }
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  // Manejar excepciones de Firebase Auth
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Usuario no encontrado');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'invalid-email':
        return Exception('Email no válido');
      case 'user-disabled':
        return Exception('Usuario deshabilitado');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intenta más tarde');
      case 'operation-not-allowed':
        return Exception('Operación no permitida');
      case 'email-already-in-use':
        return Exception('Email ya en uso');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
}
