// This file decide where user data come from, online server or offline
// cache, so rest of app don't need to worry about it.
import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required UserLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<Result<void>> createUserProfile(UserEntity user) async {
    try {
      await _remoteDataSource
          .createUserProfile(UserModel.fromEntity(user))
          .timeout(_timeout);
      return const Success(null);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Stream<Result<List<UserEntity>>> watchAllUsers({
    required String excludeUid,
  }) async* {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      yield* _cachedUsers(excludeUid);
      return;
    }

    try {
      await for (final users in _remoteDataSource.watchAllUsers(
        excludeUid: excludeUid,
      )) {
        unawaited(_localDataSource.cacheUsers(users));
        yield Success<List<UserEntity>>(users);
      }
    } catch (_) {
      yield* _cachedUsers(excludeUid);
    }
  }

  Stream<Result<List<UserEntity>>> _cachedUsers(String excludeUid) async* {
    try {
      final cached = await _localDataSource.getCachedUsers();
      yield Success(cached.where((u) => u.uid != excludeUid).toList());
    } on CacheException {
      yield const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<UserEntity>> getUserById(String uid) async {
    try {
      final user = await _remoteDataSource.getUserById(uid).timeout(_timeout);
      return Success(user);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      final cached = await _tryGetCachedUser(uid);
      if (cached != null) return Success(cached);
      return const ResultFailure(ServerFailure());
    }
  }

  Future<UserEntity?> _tryGetCachedUser(String uid) async {
    try {
      final cached = await _localDataSource.getCachedUsers();
      final matches = cached.where((u) => u.uid == uid);
      return matches.isNotEmpty ? matches.first : null;
    } on CacheException {
      return null;
    }
  }

  @override
  Future<Result<void>> updateProfile(UserEntity user) async {
    try {
      await _remoteDataSource
          .updateProfile(UserModel.fromEntity(user))
          .timeout(_timeout);
      return const Success(null);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }
}
