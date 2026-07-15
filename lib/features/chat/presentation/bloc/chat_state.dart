// This file describe one chat screen state, like message list, loading,
// which action is running, and error.
import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

enum ChatStatus { loading, loaded, error }

// Tracking *which* action is running (not just a plain isSending bool)
// lets the send button, the edit sheet, and the delete confirm each
// show their own spinner without lighting up the others too.
enum ChatSubmitAction { none, sendMessage, editMessage, deleteMessage }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.loading,
    this.messages = const [],
    this.submitAction = ChatSubmitAction.none,
    this.errorMessage,
  });

  final ChatStatus status;
  final List<MessageEntity> messages;
  final ChatSubmitAction submitAction;
  final String? errorMessage;

  bool get isSending => submitAction == ChatSubmitAction.sendMessage;
  bool get isEditingMessage => submitAction == ChatSubmitAction.editMessage;
  bool get isDeletingMessage => submitAction == ChatSubmitAction.deleteMessage;

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    ChatSubmitAction? submitAction,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      submitAction: submitAction ?? this.submitAction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, messages, submitAction, errorMessage];
}
