// This is main bloc for login system. It handle login, register,
// logout, edit profile, change password, and keep track of user status.
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../users/domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required WatchAuthStateUseCase watchAuthState,
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required UpdateProfileUseCase updateProfile,
    required UpdatePasswordUseCase updatePassword,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _updateProfile = updateProfile,
       _updatePassword = updatePassword,
       super(const AuthState()) {
    on<AuthStatusChanged>(_onStatusChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthPasswordUpdateRequested>(_onPasswordUpdateRequested);
    on<AuthErrorDismissed>(
      (event, emit) => emit(state.copyWith(clearError: true)),
    );

    _authSubscription = watchAuthState(const NoParams()).listen((result) {
      result.fold(
        (failure) => add(const AuthStatusChanged(null)),
        (user) => add(AuthStatusChanged(user)),
      );
    });
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final UpdateProfileUseCase _updateProfile;
  final UpdatePasswordUseCase _updatePassword;
  late final StreamSubscription<dynamic> _authSubscription;

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: event.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: event.user,
        submitAction: AuthSubmitAction.none,
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        submitAction: AuthSubmitAction.login,
        clearError: true,
      ),
    );
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: AuthSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          submitAction: AuthSubmitAction.none,
        ),
      ),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        submitAction: AuthSubmitAction.register,
        clearError: true,
      ),
    );
    final result = await _register(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: AuthSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          submitAction: AuthSubmitAction.none,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        submitAction: AuthSubmitAction.logout,
        clearError: true,
      ),
    );
    final result = await _logout(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: AuthSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(
      state.copyWith(
        submitAction: AuthSubmitAction.updateProfile,
        clearError: true,
      ),
    );
    final updated = currentUser.copyWith(name: event.name);
    final result = await _updateProfile(updated);
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: AuthSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: updated,
          submitAction: AuthSubmitAction.none,
        ),
      ),
    );
  }

  Future<void> _onPasswordUpdateRequested(
    AuthPasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        submitAction: AuthSubmitAction.updatePassword,
        clearError: true,
      ),
    );
    final result = await _updatePassword(
      UpdatePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: AuthSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(submitAction: AuthSubmitAction.none)),
    );
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription.cancel());
    return super.close();
  }
}
