// This file describe what login backend must do. Fake version use it
// now, real Firebase version will use same thing later.
abstract class AuthRemoteDataSource {
  Future<String> signUp({required String email, required String password});

  Future<String> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Stream<String?> watchAuthState();

  String? get currentUserId;
}
