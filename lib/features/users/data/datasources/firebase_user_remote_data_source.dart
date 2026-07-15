// This is real user profile system, using Firestore "users" collection.
// It do exact same job as the fake version, just talk to real database.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'user_remote_data_source.dart';

class FirebaseUserRemoteDataSource implements UserRemoteDataSource {
  FirebaseUserRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
    } catch (_) {
      throw const ServerException('Could not save profile.');
    }
  }

  @override
  Stream<List<UserModel>> watchAllUsers({required String excludeUid}) {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((user) => user.uid != excludeUid)
          .toList();
    });
  }

  @override
  Future<UserModel> getUserById(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        throw const ServerException('User not found.');
      }
      return UserModel.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException('Could not load profile.');
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
    } catch (_) {
      throw const ServerException('Could not update profile.');
    }
  }
}
