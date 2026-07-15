// This file test AuthBloc, check it emit right states step by step
// when user try to login (both success and wrong password case).
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_chat_app/core/error/failures.dart';
import 'package:flutter_chat_app/core/usecase/usecase.dart';
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_chat_app/features/users/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchAuthStateUseCase watchAuthState;
  late MockLoginUseCase login;
  late MockRegisterUseCase register;
  late MockLogoutUseCase logout;
  late MockUpdateProfileUseCase updateProfile;
  late MockUpdatePasswordUseCase updatePassword;

  final user = UserEntity(
    uid: 'uid1',
    name: 'Alice',
    email: 'alice@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeUpdatePasswordParams());
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    watchAuthState = MockWatchAuthStateUseCase();
    login = MockLoginUseCase();
    register = MockRegisterUseCase();
    logout = MockLogoutUseCase();
    updateProfile = MockUpdateProfileUseCase();
    updatePassword = MockUpdatePasswordUseCase();
    when(() => watchAuthState(any())).thenAnswer((_) => const Stream.empty());
  });

  AuthBloc buildBloc() => AuthBloc(
    watchAuthState: watchAuthState,
    login: login,
    register: register,
    logout: logout,
    updateProfile: updateProfile,
    updatePassword: updatePassword,
  );

  blocTest<AuthBloc, AuthState>(
    'emits submitting then authenticated when login succeeds',
    build: () {
      when(() => login(any())).thenAnswer((_) async => Success(user));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(
        email: 'alice@example.com',
        password: 'password123',
      ),
    ),
    expect: () => [
      const AuthState(submitAction: AuthSubmitAction.login),
      AuthState(
        status: AuthStatus.authenticated,
        user: user,
        submitAction: AuthSubmitAction.none,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits submitting then an error message when login fails',
    build: () {
      when(() => login(any())).thenAnswer(
        (_) async => const ResultFailure(
          AuthFailure('Invalid email or password.'),
        ),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(
        email: 'alice@example.com',
        password: 'wrong',
      ),
    ),
    expect: () => [
      const AuthState(submitAction: AuthSubmitAction.login),
      const AuthState(
        submitAction: AuthSubmitAction.none,
        errorMessage: 'Invalid email or password.',
      ),
    ],
  );
}
