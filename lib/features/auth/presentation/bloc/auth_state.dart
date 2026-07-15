// This file describe login state, like status, current user, loading
// action and error message.
import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user_entity.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthSubmitAction {
  none,
  login,
  register,
  updateProfile,
  updatePassword,
  logout,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.submitAction = AuthSubmitAction.none,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserEntity? user;
  final AuthSubmitAction submitAction;
  final String? errorMessage;

  bool get isSubmitting => submitAction != AuthSubmitAction.none;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    AuthSubmitAction? submitAction,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      submitAction: submitAction ?? this.submitAction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, submitAction, errorMessage];
}
