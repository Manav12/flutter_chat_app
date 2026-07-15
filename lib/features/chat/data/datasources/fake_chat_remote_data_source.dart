// This is fake chat backend, kept in phone memory only. It also keep
// small summary of each chat updated, for home screen preview. Delete
// this file when Firebase come.
import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/message_entity.dart';
import '../models/conversation_doc_model.dart';
import '../models/message_model.dart';
import 'chat_remote_data_source.dart';

class FakeChatRemoteDataSource implements ChatRemoteDataSource {
  FakeChatRemoteDataSource({
    this.networkDelay = const Duration(milliseconds: 500),
  });

  final Duration networkDelay;

  final Map<String, List<MessageModel>> _messagesByConversation = {};
  final Map<String, StreamController<List<MessageModel>>>
  _messageControllers = {};
  final Map<String, ConversationDocModel> _conversationDocs = {};
  final StreamController<void> _conversationsChanged =
      StreamController<void>.broadcast();

  StreamController<List<MessageModel>> _controllerFor(String conversationId) {
    return _messageControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<MessageModel>>.broadcast(),
    );
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    await Future<void>.delayed(networkDelay);
    final list = _messagesByConversation.putIfAbsent(
      message.conversationId,
      () => [],
    );
    list.add(message);
    _controllerFor(message.conversationId).add(List.unmodifiable(list));

    _conversationDocs[message.conversationId] = ConversationDocModel(
      conversationId: message.conversationId,
      participantIds: [message.senderId, message.receiverId],
      lastMessageText: message.type == MessageType.image
          ? '📷 Photo'
          : message.text,
      lastMessageSenderId: message.senderId,
      lastMessageAt: message.timestamp,
    );
    _conversationsChanged.add(null);
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return Stream<List<MessageModel>>.multi((controller) {
      controller.add(
        List.unmodifiable(
          _messagesByConversation[conversationId] ?? const <MessageModel>[],
        ),
      );
      final subscription = _controllerFor(
        conversationId,
      ).stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    await Future<void>.delayed(networkDelay);
    final list = _messagesByConversation[conversationId];
    if (list == null) throw const ServerException('Conversation not found.');
    final index = list.indexWhere((m) => m.id == messageId);
    if (index == -1) throw const ServerException('Message not found.');

    final updated = MessageModel.fromEntity(
      list[index].copyWith(text: newText, editedAt: DateTime.now()),
    );
    list[index] = updated;
    _controllerFor(conversationId).add(List.unmodifiable(list));

    if (list.isNotEmpty && list.last.id == messageId) {
      _refreshConversationDoc(conversationId, list);
    }
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await Future<void>.delayed(networkDelay);
    final list = _messagesByConversation[conversationId];
    if (list == null) throw const ServerException('Conversation not found.');
    list.removeWhere((m) => m.id == messageId);
    _controllerFor(conversationId).add(List.unmodifiable(list));
    _refreshConversationDoc(conversationId, list);
  }

  void _refreshConversationDoc(
    String conversationId,
    List<MessageModel> messages,
  ) {
    final existing = _conversationDocs[conversationId];
    if (existing == null) return;

    if (messages.isEmpty) {
      _conversationDocs[conversationId] = ConversationDocModel(
        conversationId: conversationId,
        participantIds: existing.participantIds,
      );
    } else {
      final last = messages.last;
      _conversationDocs[conversationId] = ConversationDocModel(
        conversationId: conversationId,
        participantIds: existing.participantIds,
        lastMessageText: last.type == MessageType.image
            ? '📷 Photo'
            : last.text,
        lastMessageSenderId: last.senderId,
        lastMessageAt: last.timestamp,
      );
    }
    _conversationsChanged.add(null);
  }

  @override
  Stream<List<ConversationDocModel>> watchConversations(
    String currentUserId,
  ) {
    List<ConversationDocModel> currentDocsFor(String uid) => _conversationDocs
        .values
        .where((doc) => doc.participantIds.contains(uid))
        .toList();

    return Stream<List<ConversationDocModel>>.multi((controller) {
      controller.add(currentDocsFor(currentUserId));
      final subscription = _conversationsChanged.stream.listen((_) {
        controller.add(currentDocsFor(currentUserId));
      });
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<String> uploadChatImage({
    required String conversationId,
    required String localFilePath,
  }) async {
    await Future<void>.delayed(networkDelay);
    return localFilePath;
  }
}
