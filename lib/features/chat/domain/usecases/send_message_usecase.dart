// This file handle sending one text message.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';
import '../utils/conversation_id.dart';

class SendMessageParams {
  const SendMessageParams({
    required this.senderId,
    required this.receiverId,
    required this.text,
  });

  final String senderId;
  final String receiverId;
  final String text;
}

class SendMessageUseCase extends UseCase<void, SendMessageParams> {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(SendMessageParams params) {
    final message = MessageEntity(
      id: IdGenerator.generate(),
      conversationId: buildConversationId(params.senderId, params.receiverId),
      senderId: params.senderId,
      receiverId: params.receiverId,
      text: params.text.trim(),
      timestamp: DateTime.now(),
    );
    return _repository.sendMessage(message);
  }
}
