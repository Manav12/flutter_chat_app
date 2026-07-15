// This is chat screen bloc. It watch messages of one conversation live,
// and handle send, edit, delete message.
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_message_usecase.dart';
import '../../domain/usecases/edit_message_usecase.dart';
import '../../domain/usecases/mark_conversation_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/watch_messages_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required WatchMessagesUseCase watchMessages,
    required SendMessageUseCase sendMessage,
    required EditMessageUseCase editMessage,
    required DeleteMessageUseCase deleteMessage,
    required MarkConversationReadUseCase markConversationRead,
  }) : _watchMessages = watchMessages,
       _sendMessage = sendMessage,
       _editMessage = editMessage,
       _deleteMessage = deleteMessage,
       _markConversationRead = markConversationRead,
       super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessagesUpdated>(_onMessagesUpdated);
    on<ChatTextMessageSent>(_onTextMessageSent);
    on<ChatMessageEditRequested>(_onEditRequested);
    on<ChatMessageDeleteRequested>(_onDeleteRequested);
    on<ChatErrorDismissed>(
      (event, emit) => emit(state.copyWith(clearError: true)),
    );
  }

  final WatchMessagesUseCase _watchMessages;
  final SendMessageUseCase _sendMessage;
  final EditMessageUseCase _editMessage;
  final DeleteMessageUseCase _deleteMessage;
  final MarkConversationReadUseCase _markConversationRead;

  String? _currentUserId;
  String? _peerId;
  StreamSubscription<dynamic>? _messagesSubscription;

  void _onStarted(ChatStarted event, Emitter<ChatState> emit) {
    _currentUserId = event.currentUserId;
    _peerId = event.peerId;
    unawaited(_messagesSubscription?.cancel());
    _messagesSubscription = _watchMessages(
      WatchMessagesParams(
        currentUserId: event.currentUserId,
        peerId: event.peerId,
      ),
    ).listen((result) => add(ChatMessagesUpdated(result)));
    unawaited(
      _markConversationRead(
        MarkConversationReadParams(
          currentUserId: event.currentUserId,
          peerId: event.peerId,
        ),
      ),
    );
  }

  void _onMessagesUpdated(ChatMessagesUpdated event, Emitter<ChatState> emit) {
    event.result.fold(
      (failure) => emit(
        state.copyWith(status: ChatStatus.error, errorMessage: failure.message),
      ),
      (messages) => emit(
        state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onTextMessageSent(
    ChatTextMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final senderId = _currentUserId;
    final receiverId = _peerId;
    if (senderId == null || receiverId == null) return;

    emit(
      state.copyWith(
        submitAction: ChatSubmitAction.sendMessage,
        clearError: true,
      ),
    );
    final result = await _sendMessage(
      SendMessageParams(
        senderId: senderId,
        receiverId: receiverId,
        text: event.text,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: ChatSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(submitAction: ChatSubmitAction.none)),
    );
  }

  Future<void> _onEditRequested(
    ChatMessageEditRequested event,
    Emitter<ChatState> emit,
  ) async {
    final currentUserId = _currentUserId;
    final peerId = _peerId;
    if (currentUserId == null || peerId == null) return;

    emit(
      state.copyWith(
        submitAction: ChatSubmitAction.editMessage,
        clearError: true,
      ),
    );
    final result = await _editMessage(
      EditMessageParams(
        currentUserId: currentUserId,
        peerId: peerId,
        messageId: event.messageId,
        newText: event.newText,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: ChatSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(submitAction: ChatSubmitAction.none)),
    );
  }

  Future<void> _onDeleteRequested(
    ChatMessageDeleteRequested event,
    Emitter<ChatState> emit,
  ) async {
    final currentUserId = _currentUserId;
    final peerId = _peerId;
    if (currentUserId == null || peerId == null) return;

    emit(
      state.copyWith(
        submitAction: ChatSubmitAction.deleteMessage,
        clearError: true,
      ),
    );
    final result = await _deleteMessage(
      DeleteMessageParams(
        currentUserId: currentUserId,
        peerId: peerId,
        messageId: event.messageId,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitAction: ChatSubmitAction.none,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(submitAction: ChatSubmitAction.none)),
    );
  }

  @override
  Future<void> close() {
    unawaited(_messagesSubscription?.cancel());
    return super.close();
  }
}
