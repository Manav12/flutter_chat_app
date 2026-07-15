// This file handle deleting a message.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/chat_repository.dart';
import '../utils/conversation_id.dart';

class DeleteMessageParams {
  const DeleteMessageParams({
    required this.currentUserId,
    required this.peerId,
    required this.messageId,
  });

  final String currentUserId;
  final String peerId;
  final String messageId;
}

class DeleteMessageUseCase extends UseCase<void, DeleteMessageParams> {
  const DeleteMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(DeleteMessageParams params) {
    return _repository.deleteMessage(
      conversationId: buildConversationId(
        params.currentUserId,
        params.peerId,
      ),
      messageId: params.messageId,
    );
  }
}
