import '../../../../core/utils/result.dart';

/// Handles just logging in, signing up, and logging out. Profile info
/// like name and photo lives in `UserRepository` instead, so login stuff
/// and profile stuff can each change without breaking the other.
abstract class AuthRepository {
  /// Creates a new account and gives back the new user's id.
  Future<Result<String>> signUp({required String email, required String password});

  /// Logs in and gives back that user's id.
  Future<Result<String>> signIn({required String email, required String password});

  Future<Result<void>> signOut();

  /// Tells us who's logged in right now, and sends `null` when nobody is.
  /// This is what lets the app remember you're logged in after you close
  /// and reopen it.
  Stream<String?> watchAuthState();

  String? get currentUserId;
}
