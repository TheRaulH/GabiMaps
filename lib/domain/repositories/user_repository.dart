import 'package:gabimaps/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> getUser(String uid);
  Future<void> saveUser(User user);
}
