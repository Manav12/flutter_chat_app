// This file test AuthRepositoryImpl, check it turn different kind of
// error (wrong password, timeout, anything else) into right Failure.
import 'dart:async';

import 'package:flutter_chat_app/core/error/exceptions.dart';
import 'package:flutter_chat_app/core/error/failures.dart';
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource);
  });

  group('signIn', () {
    test('returns Success with the uid when sign in works', () async {
      when(
        () => remoteDataSource.signIn(email: 'a@b.com', password: 'pw'),
      ).thenAnswer((_) async => 'uid1');

      final result = await repository.signIn(
        email: 'a@b.com',
        password: 'pw',
      );

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'uid1');
    });

    test('maps AuthException to AuthFailure with the same message', () async {
      when(
        () => remoteDataSource.signIn(email: 'a@b.com', password: 'pw'),
      ).thenThrow(const AuthException('Invalid email or password.'));

      final result = await repository.signIn(
        email: 'a@b.com',
        password: 'pw',
      );

      expect(result, isA<ResultFailure<String>>());
      final failure = (result as ResultFailure<String>).failure;
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Invalid email or password.');
    });

    test('maps a timeout to TimeoutFailure', () async {
      when(
        () => remoteDataSource.signIn(email: 'a@b.com', password: 'pw'),
      ).thenThrow(TimeoutException('too slow'));

      final result = await repository.signIn(
        email: 'a@b.com',
        password: 'pw',
      );

      expect(result, isA<ResultFailure<String>>());
      expect((result as ResultFailure<String>).failure, isA<TimeoutFailure>());
    });

    test('maps any other error to ServerFailure', () async {
      when(
        () => remoteDataSource.signIn(email: 'a@b.com', password: 'pw'),
      ).thenThrow(Exception('boom'));

      final result = await repository.signIn(
        email: 'a@b.com',
        password: 'pw',
      );

      expect(result, isA<ResultFailure<String>>());
      expect((result as ResultFailure<String>).failure, isA<ServerFailure>());
    });
  });
}
