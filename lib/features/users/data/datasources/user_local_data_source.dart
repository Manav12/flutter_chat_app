// This file describe user list cache on phone, used when no internet.
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<List<UserModel>> getCachedUsers();

  Future<void> cacheUsers(List<UserModel> users);

  bool get isCacheStale;
}
