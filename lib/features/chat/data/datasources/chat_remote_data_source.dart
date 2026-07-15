// This file describe what chat backend must do, like send, watch, edit,
// delete message and upload photo.
import '../models/conversation_doc_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);

  Stream<List<MessageModel>> watchMessages(String conversationId);

  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  });

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  });

  Stream<List<ConversationDocModel>> watchConversations(String currentUserId);

  Future<String> uploadChatImage({
    required String conversationId,
    required String localFilePath,
  });
}
