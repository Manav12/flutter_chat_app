// This file test LoginUseCase, check it correctly join sign-in step and
// profile-fetch step, using fake AuthRepository and UserRepository.
import 'package:flutter_chat_app/core/error/failures.dart';
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_chat_app/features/users/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockUserRepository userRepository;
  late LoginUseCase useCase;

  setUp(() {
    authRepository = MockAuthRepository();
    userRepository = MockUserRepository();
    useCase = LoginUseCase(authRepository, userRepository);
  });

  const params = LoginParams(
    email: 'alice@example.com',
    password: 'password123',
  );
  final user = UserEntity(
    uid: 'uid1',
    name: 'Alice',
    email: 'alice@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  test('returns the user when sign in and profile fetch both succeed', () async {
    when(
      () => authRepository.signIn(
        email: params.email,
        password: params.password,
      ),
    ).thenAnswer((_) async => const Success('uid1'));
    when(
      () => userRepository.getUserById('uid1'),
    ).thenAnswer((_) async => Success(user));

    final result = await useCase(params);

    expect(result, isA<Success<UserEntity>>());
    expect((result as Success<UserEntity>).data, user);
    verify(() => userRepository.getUserById('uid1')).called(1);
  });

  test(
    'returns the failure and never checks the profile when sign in fails',
    () async {
      const failure = AuthFailure('Invalid email or password.');
      when(
        () => authRepository.signIn(
          email: params.email,
          password: params.password,
        ),
      ).thenAnswer((_) async => const ResultFailure(failure));

      final result = await useCase(params);

      expect(result, isA<ResultFailure<UserEntity>>());
      expect((result as ResultFailure<UserEntity>).failure, failure);
      verifyNever(() => userRepository.getUserById(any()));
    },
  );

  test(
    'returns the failure when sign in succeeds but profile fetch fails',
    () async {
      when(
        () => authRepository.signIn(
          email: params.email,
          password: params.password,
        ),
      ).thenAnswer((_) async => const Success('uid1'));
      when(() => userRepository.getUserById('uid1')).thenAnswer(
        (_) async => const ResultFailure(ServerFailure()),
      );

      final result = await useCase(params);

      expect(result, isA<ResultFailure<UserEntity>>());
    },
  );
}
