import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/domain/entities/user.dart';
import 'package:gabimaps/domain/usecases/user_usecases.dart';
import 'package:gabimaps/domain/repositories/user_repository.dart';
import 'package:gabimaps/data/repositories/user_repository_impl.dart';
import 'package:gabimaps/services/firestore_service.dart'; // Importa FirestoreService

// Proporciona FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// Proporciona UserRepository
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(firestoreServiceProvider)),
);

// Proporciona GetUser usecase
final getUserProvider = Provider<GetUser>(
  (ref) => GetUser(ref.read(userRepositoryProvider)),
);

// Proporciona SaveUser usecase
final saveUserProvider = Provider<SaveUser>(
  (ref) => SaveUser(ref.read(userRepositoryProvider)),
);

// Proporciona UserNotifier
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final getUser = ref.read(getUserProvider);
  final saveUser = ref.read(saveUserProvider);
  return UserNotifier(getUser, saveUser);
});

class UserNotifier extends StateNotifier<User?> {
  final GetUser _getUser;
  final SaveUser _saveUser;

  UserNotifier(this._getUser, this._saveUser) : super(null);

  Future<void> fetchUser(String uid) async {
    state = await _getUser.execute(uid);
  }

  Future<void> updateUser(User user) async {
    await _saveUser.execute(user);
    state = user;
  }
}
