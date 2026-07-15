// This is real cache for chat messages, using Hive storage on phone.
import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/message_model.dart';
import 'chat_local_data_source.dart';

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  ChatLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<List<MessageModel>> getCachedMessages(String conversationId) async {
    final raw = _box.get(conversationId) as List<dynamic>?;
    if (raw == null) {
      throw const CacheException('No cached messages available.');
    }
    return raw
        .map(
          (item) =>
              MessageModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> cacheMessages(
    String conversationId,
    List<MessageModel> messages,
  ) async {
    await _box.put(conversationId, messages.map((m) => m.toJson()).toList());
  }
}
