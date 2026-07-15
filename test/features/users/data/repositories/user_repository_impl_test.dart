// This file test UserRepositoryImpl, check it use live data when
// online, fall back to cache when offline, and report network failure
// when offline with nothing cached yet.
import 'package:flutter_chat_app/core/error/exceptions.dart';
import 'package:flutter_chat_app/core/error/failures.dart';
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/users/data/models/user_model.dart';
import 'package:flutter_chat_app/features/users/data/repositories/user_repository_impl.dart';
import 'package:flutter_chat_app/features/users/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockUserRemoteDataSource remoteDataSource;
  late MockUserLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late UserRepositoryImpl repository;

  final aliceModel = UserModel(
    uid: 'alice',
    name: 'Alice',
    email: 'a@x.com',
    createdAt: DateTime(2024, 1, 1),
  );
  final bobModel = UserModel(
    uid: 'bob',
    name: 'Bob',
    email: 'b@x.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(<UserModel>[]);
  });

  setUp(() {
    remoteDataSource = MockUserRemoteDataSource();
    localDataSource = MockUserLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = UserRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
    when(() => localDataSource.cacheUsers(any())).thenAnswer((_) async {});
  });

  test('online: streams live users and writes them to cache', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(
      () => remoteDataSource.watchAllUsers(excludeUid: 'me'),
    ).thenAnswer((_) => Stream.value([aliceModel, bobModel]));

    final result = await repository.watchAllUsers(excludeUid: 'me').first;

    expect(result, isA<Success<List<UserEntity>>>());
    expect(
      (result as Success<List<UserEntity>>).data,
      [aliceModel, bobModel],
    );
    verify(() => localDataSource.cacheUsers([aliceModel, bobModel])).called(1);
  });

  test(
    'offline: falls back to whatever is cached, excluding the current user',
    () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.getCachedUsers(),
      ).thenAnswer((_) async => [aliceModel, bobModel]);

      final result = await repository.watchAllUsers(excludeUid: 'alice').first;

      expect(result, isA<Success<List<UserEntity>>>());
      expect((result as Success<List<UserEntity>>).data, [bobModel]);
      verifyNever(
        () => remoteDataSource.watchAllUsers(
          excludeUid: any(named: 'excludeUid'),
        ),
      );
    },
  );

  test('offline with nothing cached yet: reports a network failure', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(() => localDataSource.getCachedUsers()).thenThrow(
      const CacheException(),
    );

    final result = await repository.watchAllUsers(excludeUid: 'me').first;

    expect(result, isA<ResultFailure<List<UserEntity>>>());
    expect(
      (result as ResultFailure<List<UserEntity>>).failure,
      isA<NetworkFailure>(),
    );
  });
}
