// This file change user data to JSON and back, so we can save and load
// it from Firestore or Hive.
import 'dart:convert';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.createdAt,
    super.photoUrl,
  });

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    uid: entity.uid,
    name: entity.name,
    email: entity.email,
    createdAt: entity.createdAt,
    photoUrl: entity.photoUrl,
  );

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] is int
            ? json['createdAt'] as int
            : int.tryParse(json['createdAt']?.toString() ?? '') ?? 0,
      ),
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'photoUrl': photoUrl,
  };
}
