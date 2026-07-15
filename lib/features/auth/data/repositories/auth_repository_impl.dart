// This file connect login use case to actual data source, and change
// error into Failure app can understand.
import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<Result<String>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final uid = await _remoteDataSource
          .signUp(email: email, password: password)
          .timeout(_timeout);
      return Success(uid);
    } on AuthException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Future<Result<String>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final uid = await _remoteDataSource
          .signIn(email: email, password: password)
          .timeout(_timeout);
      return Success(uid);
    } on AuthException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut().timeout(_timeout);
      return const Success(null);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource
          .updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          )
          .timeout(_timeout);
      return const Success(null);
    } on AuthException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Stream<String?> watchAuthState() => _remoteDataSource.watchAuthState();

  @override
  String? get currentUserId => _remoteDataSource.currentUserId;
}
