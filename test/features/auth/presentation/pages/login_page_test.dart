// This file test LoginPage, check it show validation error and does
// not call login use case when form is submitted empty.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/core/usecase/usecase.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/login_page.dart';
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
  late AuthBloc authBloc;

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
    authBloc = AuthBloc(
      watchAuthState: watchAuthState,
      login: login,
      register: register,
      logout: logout,
      updateProfile: updateProfile,
      updatePassword: updatePassword,
    );
  });

  tearDown(() => authBloc.close());

  testWidgets('shows validation errors when submitting an empty form', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => login(any()));
  });
}
