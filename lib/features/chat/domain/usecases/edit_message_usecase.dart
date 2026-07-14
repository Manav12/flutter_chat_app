import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/chat_repository.dart';
import '../utils/conversation_id.dart';

class EditMessageParams {
  const EditMessageParams({
    required this.currentUserId,
    required this.peerId,
    required this.messageId,
    required this.newText,
  });

  final String currentUserId;
  final String peerId;
  final String messageId;
  final String newText;
}

class EditMessageUseCase extends UseCase<void, EditMessageParams> {
  const EditMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(EditMessageParams params) {
    return _repository.editMessage(
      conversationId: buildConversationId(
        params.currentUserId,
        params.peerId,
      ),
      messageId: params.messageId,
      newText: params.newText.trim(),
    );
  }
}
