// user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/data/models/user_model.dart';

// Estados del provider
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// Notifier
class UserNotifier extends StateNotifier<UserState> {
  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _auth;

  UserNotifier({
    required FirebaseFirestore firestore,
    required auth.FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth,
       super(UserInitial()) {
    loadUser();
  }

  Future<void> loadUser() async {
    state = UserLoading();
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        state = UserError('No hay usuario autenticado');
        return;
      }

      final userData =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userData.exists) {
        final user = UserModel.fromFirestore(
          userData.data() as Map<String, dynamic>,
          currentUser.uid,
        );
        state = UserLoaded(user);
      } else {
        // Crear un usuario básico si no existe en Firestore
        final newUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          rol: 'usuario',
          fechaRegistro: DateTime.now(),
          photoURL: currentUser.photoURL,
        );

        await _saveUserToFirestore(newUser);
        state = UserLoaded(newUser);
      }
    } catch (e) {
      state = UserError('Error al cargar el usuario: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final previousState = state;
      state = UserLoading();

      await _saveUserToFirestore(user);
      state = UserLoaded(user);
    } catch (e) {
      state = UserError('Error al actualizar el usuario: $e');
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }
}

// Provider de Firebase
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<auth.FirebaseAuth>((ref) {
  return auth.FirebaseAuth.instance;
});

// Provider principal
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final userListProvider =
    StateNotifierProvider<UserListNotifier, List<UserModel>>((ref) {
      return UserListNotifier(ref);
    });

class UserListNotifier extends StateNotifier<List<UserModel>> {
  final Ref ref;

  UserListNotifier(this.ref) : super([]) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    final firestore = ref.read(firebaseFirestoreProvider);
    final snapshot = await firestore.collection('users').get();
    state =
        snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
            .toList();
  }

  Future<void> deleteUser(String uid) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore.collection('users').doc(uid).delete();
    state = state.where((user) => user.uid != uid).toList();
  }

  Future<void> updateUser(UserModel user) async {
    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
    await loadUsers();
  }
}
