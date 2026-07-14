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

  /// Every chat [currentUserId] is part of, each with its newest message
  /// attached — this is what fills the home screen's list.
  Stream<Result<List<ConversationPreview>>> watchConversations(
    String currentUserId,
  );

  /// Uploads a photo for a message and gives back a link to it.
  Future<Result<String>> uploadChatImage({
    required String conversationId,
    required String localFilePath,
  });
}
