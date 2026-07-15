// This file describe message cache on phone, one list per chat, used
// when no internet.
import '../models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<MessageModel>> getCachedMessages(String conversationId);

  Future<void> cacheMessages(
    String conversationId,
    List<MessageModel> messages,
  );
}
