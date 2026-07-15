// This file describe what user profile look like, like name, email.
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserEntity copyWith({String? name}) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, createdAt];
}
