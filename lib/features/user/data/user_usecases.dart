import 'package:gabimaps/features/user/data/user.dart';
import 'package:gabimaps/features/user/data/user_repository.dart';

class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  Future<User?> execute(String uid) async {
    return repository.getUser(uid);
  }
}

class SaveUser {
  final UserRepository repository;

  SaveUser(this.repository);

  Future<void> execute(User user) async {
    return repository.saveUser(user);
  }
}
