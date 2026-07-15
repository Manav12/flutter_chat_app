// This file describe what user profile system can do, like save, list
// and update profile.
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<void>> createUserProfile(UserEntity user);

  Stream<Result<List<UserEntity>>> watchAllUsers({required String excludeUid});

  Future<Result<UserEntity>> getUserById(String uid);

  Future<Result<void>> updateProfile(UserEntity user);
}
