import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';
import '../utils/conversation_id.dart';

class SendImageMessageParams {
  const SendImageMessageParams({
    required this.senderId,
    required this.receiverId,
    required this.localFilePath,
  });

  final String senderId;
  final String receiverId;
  final String localFilePath;
}

/// Uploads the photo first, then sends a message that points to it.
/// The bloc doesn't need to know it's two steps — it just gets back one
/// success or one failure at the end.
class SendImageMessageUseCase extends UseCase<void, SendImageMessageParams> {
  const SendImageMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(SendImageMessageParams params) async {
    final conversationId = buildConversationId(
      params.senderId,
      params.receiverId,
    );

    final uploadResult = await _repository.uploadChatImage(
      conversationId: conversationId,
      localFilePath: params.localFilePath,
    );

    return uploadResult.fold((failure) async => ResultFailure(failure), (
      mediaUrl,
    ) {
      final message = MessageEntity(
        id: IdGenerator.generate(),
        conversationId: conversationId,
        senderId: params.senderId,
        receiverId: params.receiverId,
        text: '',
        type: MessageType.image,
        timestamp: DateTime.now(),
        mediaUrl: mediaUrl,
      );
      return _repository.sendMessage(message);
    });
  }
}
