// This file list actions user can do inside one chat, like send, edit,
// delete message.
import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/message_entity.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted({required this.currentUserId, required this.peerId});
  final String currentUserId;
  final String peerId;
  @override
  List<Object?> get props => [currentUserId, peerId];
}

class ChatMessagesUpdated extends ChatEvent {
  const ChatMessagesUpdated(this.result);
  final Result<List<MessageEntity>> result;
  @override
  List<Object?> get props => [result];
}

class ChatTextMessageSent extends ChatEvent {
  const ChatTextMessageSent(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class ChatMessageEditRequested extends ChatEvent {
  const ChatMessageEditRequested({
    required this.messageId,
    required this.newText,
  });
  final String messageId;
  final String newText;
  @override
  List<Object?> get props => [messageId, newText];
}

class ChatMessageDeleteRequested extends ChatEvent {
  const ChatMessageDeleteRequested(this.messageId);
  final String messageId;
  @override
  List<Object?> get props => [messageId];
}

class ChatErrorDismissed extends ChatEvent {
  const ChatErrorDismissed();
}
