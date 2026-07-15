// This file describe what user profile backend must do.
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> createUserProfile(UserModel user);

  Stream<List<UserModel>> watchAllUsers({required String excludeUid});

  Future<UserModel> getUserById(String uid);

  Future<void> updateProfile(UserModel user);
}
