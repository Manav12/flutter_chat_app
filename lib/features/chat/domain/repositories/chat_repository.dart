// This file describe what chat system can do, like send, edit, delete,
// and watch message.
import '../../../../core/utils/result.dart';
import '../entities/conversation_preview.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Result<void>> sendMessage(MessageEntity message);

  Stream<Result<List<MessageEntity>>> watchMessages(String conversationId);

  Future<Result<void>> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  });

  Future<Result<void>> deleteMessage({
    required String conversationId,
    required String messageId,
  });

  Stream<Result<List<ConversationPreview>>> watchConversations(
    String currentUserId,
  );

  Future<Result<void>> markConversationRead({
    required String conversationId,
    required String currentUserId,
    required String peerId,
  });
}
