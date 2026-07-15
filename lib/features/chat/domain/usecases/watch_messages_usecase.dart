// This file get live message list for one chat.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';
import '../utils/conversation_id.dart';

class WatchMessagesParams {
  const WatchMessagesParams({
    required this.currentUserId,
    required this.peerId,
  });

  final String currentUserId;
  final String peerId;
}

class WatchMessagesUseCase
    extends StreamUseCase<List<MessageEntity>, WatchMessagesParams> {
  const WatchMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Stream<Result<List<MessageEntity>>> call(WatchMessagesParams params) {
    final conversationId = buildConversationId(
      params.currentUserId,
      params.peerId,
    );
    return _repository.watchMessages(conversationId);
  }
}
