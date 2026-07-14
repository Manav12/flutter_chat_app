import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Saves a new user's profile to Firestore when they sign up.
  Future<Result<void>> createUserProfile(UserEntity user);

  /// A live, always-updating list of every user except yourself
  /// ([excludeUid]) — this is what fills the home screen's user list.
  Stream<Result<List<UserEntity>>> watchAllUsers({required String excludeUid});

  Future<Result<UserEntity>> getUserById(String uid);

  Future<Result<void>> updateProfile(UserEntity user);
}
