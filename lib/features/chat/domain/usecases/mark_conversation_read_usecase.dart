// This file handle marking a conversation as read, so its unread count
// go back to zero once you open it.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/chat_repository.dart';
import '../utils/conversation_id.dart';

class MarkConversationReadParams {
  const MarkConversationReadParams({
    required this.currentUserId,
    required this.peerId,
  });

  final String currentUserId;
  final String peerId;
}

class MarkConversationReadUseCase
    extends UseCase<void, MarkConversationReadParams> {
  const MarkConversationReadUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Result<void>> call(MarkConversationReadParams params) {
    return _repository.markConversationRead(
      conversationId: buildConversationId(
        params.currentUserId,
        params.peerId,
      ),
      currentUserId: params.currentUserId,
      peerId: params.peerId,
    );
  }
}
