// This is real cache for user list, using Hive storage on phone.
import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'user_local_data_source.dart';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const String _usersKey = 'cached_users';
  static const String _cachedAtKey = 'cached_users_at';
  static const Duration staleAfter = Duration(minutes: 10);

  @override
  Future<List<UserModel>> getCachedUsers() async {
    final raw = _box.get(_usersKey) as List<dynamic>?;
    if (raw == null) {
      throw const CacheException('No cached users available.');
    }
    return raw
        .map(
          (item) => UserModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    await _box.put(_usersKey, users.map((u) => u.toJson()).toList());
    await _box.put(_cachedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  bool get isCacheStale {
    final cachedAtMillis = _box.get(_cachedAtKey) as int?;
    if (cachedAtMillis == null) return true;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    return DateTime.now().difference(cachedAt) > staleAfter;
  }
}
