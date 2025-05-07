import 'package:gabimaps/features/user/data/user.dart';

abstract class UserRepository {
  Future<User?> getUser(String uid);
  Future<void> saveUser(User user);
}
