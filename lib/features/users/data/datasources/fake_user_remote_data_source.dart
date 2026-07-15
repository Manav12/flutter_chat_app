// This is fake user list backend, kept in phone memory only. Delete
// this file when Firebase come.
import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/demo_seed_users.dart';
import '../models/user_model.dart';
import 'user_remote_data_source.dart';

class FakeUserRemoteDataSource implements UserRemoteDataSource {
  FakeUserRemoteDataSource({
    this.networkDelay = const Duration(milliseconds: 500),
  }) {
    for (final seed in demoSeedUsers) {
      _users.add(
        UserModel(
          uid: seed.uid,
          name: seed.name,
          email: seed.email,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  final Duration networkDelay;
  final List<UserModel> _users = [];
  final StreamController<List<UserModel>> _usersController =
      StreamController<List<UserModel>>.broadcast();

  void _emitChange() => _usersController.add(List.unmodifiable(_users));

  @override
  Future<void> createUserProfile(UserModel user) async {
    await Future<void>.delayed(networkDelay);
    final alreadyExists = _users.any((u) => u.uid == user.uid);
    if (!alreadyExists) {
      _users.add(user);
      _emitChange();
    }
  }

  @override
  Future<UserModel> getUserById(String uid) async {
    await Future<void>.delayed(networkDelay);
    final matches = _users.where((u) => u.uid == uid);
    if (matches.isEmpty) {
      throw const ServerException('User not found.');
    }
    return matches.first;
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await Future<void>.delayed(networkDelay);
    final index = _users.indexWhere((u) => u.uid == user.uid);
    if (index == -1) {
      throw const ServerException('User not found.');
    }
    _users[index] = user;
    _emitChange();
  }

  @override
  Stream<List<UserModel>> watchAllUsers({required String excludeUid}) {
    return Stream<List<UserModel>>.multi((controller) {
      controller.add(_users.where((u) => u.uid != excludeUid).toList());
      final subscription = _usersController.stream.listen((users) {
        controller.add(users.where((u) => u.uid != excludeUid).toList());
      });
      controller.onCancel = subscription.cancel;
    });
  }
}
