// This is fake login system, kept in phone memory only. Used so app
// can run and test before real Firebase come. Delete this file later.
import 'dart:async';
import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/demo_seed_users.dart';
import 'auth_remote_data_source.dart';

class _Account {
  _Account({required this.uid, required this.email, required this.password});
  final String uid;
  final String email;
  String password;
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource({
    this.networkDelay = const Duration(milliseconds: 500),
  }) {
    for (final seed in demoSeedUsers) {
      _accounts.add(
        _Account(uid: seed.uid, email: seed.email, password: demoSeedPassword),
      );
    }
  }

  final Duration networkDelay;

  final List<_Account> _accounts = [];
  final StreamController<String?> _authController =
      StreamController<String?>.broadcast();
  String? _currentUserId;

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(networkDelay);
    final normalizedEmail = email.trim().toLowerCase();
    final alreadyTaken = _accounts.any(
      (account) => account.email == normalizedEmail,
    );
    if (alreadyTaken) {
      throw const AuthException('An account with this email already exists.');
    }
    final uid = 'uid_${Random().nextInt(1 << 32)}';
    _accounts.add(
      _Account(uid: uid, email: normalizedEmail, password: password),
    );
    _currentUserId = uid;
    _authController.add(uid);
    return uid;
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(networkDelay);
    final normalizedEmail = email.trim().toLowerCase();
    final matches = _accounts.where(
      (account) =>
          account.email == normalizedEmail && account.password == password,
    );
    if (matches.isEmpty) {
      throw const AuthException('Invalid email or password.');
    }
    final uid = matches.first.uid;
    _currentUserId = uid;
    _authController.add(uid);
    return uid;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(networkDelay);
    _currentUserId = null;
    _authController.add(null);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(networkDelay);
    final uid = _currentUserId;
    if (uid == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    final matches = _accounts.where((account) => account.uid == uid);
    if (matches.isEmpty) {
      throw const AuthException('Account not found.');
    }
    final account = matches.first;
    if (account.password != currentPassword) {
      throw const AuthException('Current password is incorrect.');
    }
    account.password = newPassword;
  }

  @override
  Stream<String?> watchAuthState() {
    return Stream<String?>.multi((controller) {
      controller.add(_currentUserId);
      final subscription = _authController.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }
}
