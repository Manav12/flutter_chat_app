// This file list all action user can do on login system, like login,
// register, logout, edit name, change password.
import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user_entity.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged(this.user);
  final UserEntity? user;
  @override
  List<Object?> get props => [user];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
  @override
  List<Object?> get props => [name, email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileUpdateRequested extends AuthEvent {
  const AuthProfileUpdateRequested({this.name});
  final String? name;
  @override
  List<Object?> get props => [name];
}

class AuthPasswordUpdateRequested extends AuthEvent {
  const AuthPasswordUpdateRequested({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthErrorDismissed extends AuthEvent {
  const AuthErrorDismissed();
}
