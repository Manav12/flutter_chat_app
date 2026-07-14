import 'package:equatable/equatable.dart';

/// A user's profile: name, email, photo. This is saved in Firestore's
/// `users` collection and used by login, the user list, and chat.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;

  UserEntity copyWith({String? name, String? photoUrl}) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email,
      createdAt: createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, createdAt, photoUrl];
}
