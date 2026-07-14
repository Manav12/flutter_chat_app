import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/conversation_preview.dart';
import '../repositories/chat_repository.dart';

class WatchConversationsParams {
  const WatchConversationsParams({required this.currentUserId});
  final String currentUserId;
}

class WatchConversationsUseCase
    extends
        StreamUseCase<List<ConversationPreview>, WatchConversationsParams> {
  const WatchConversationsUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Stream<Result<List<ConversationPreview>>> call(
    WatchConversationsParams params,
  ) {
    return _repository.watchConversations(params.currentUserId);
  }
}
