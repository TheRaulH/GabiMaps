import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/data/users_repository.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getAllUsers();
});

final adminUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getUsersByRole('admin');
});

final userListFilterProvider = StateProvider<String>((ref) => 'all');

final filteredUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final filter = ref.watch(userListFilterProvider);
  final repository = ref.watch(usersRepositoryProvider);

  switch (filter) {
    case 'admin':
      return repository.getUsersByRole('admin');
    case 'user':
      return repository.getUsersByRole('user');
    case 'institutional':
      return repository.getUsersByRole('institutional');
    case 'entrepreneur':
      return repository.getUsersByRole('entrepreneur');
    default:
      return repository.getAllUsers();
  }
});
