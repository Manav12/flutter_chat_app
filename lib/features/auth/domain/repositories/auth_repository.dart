// This file describe what login system can do, like signup, signin,
// signout, change password. Real work happen in data layer.
import '../../../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<String>> signUp({required String email, required String password});

  Future<Result<String>> signIn({required String email, required String password});

  Future<Result<void>> signOut();

  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Stream<String?> watchAuthState();

  String? get currentUserId;
}
