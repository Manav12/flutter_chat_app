// This file test ChatBloc, check it show a spinner while sending
// message, then clear it on success or show error message on failure.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_chat_app/core/error/failures.dart';
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchMessagesUseCase watchMessages;
  late MockSendMessageUseCase sendMessage;
  late MockSendImageMessageUseCase sendImageMessage;
  late MockEditMessageUseCase editMessage;
  late MockDeleteMessageUseCase deleteMessage;

  setUpAll(() {
    registerFallbackValue(FakeWatchMessagesParams());
    registerFallbackValue(FakeSendMessageParams());
    registerFallbackValue(FakeSendImageMessageParams());
  });

  setUp(() {
    watchMessages = MockWatchMessagesUseCase();
    sendMessage = MockSendMessageUseCase();
    sendImageMessage = MockSendImageMessageUseCase();
    editMessage = MockEditMessageUseCase();
    deleteMessage = MockDeleteMessageUseCase();
    when(() => watchMessages(any())).thenAnswer((_) => const Stream.empty());
  });

  ChatBloc buildBloc() => ChatBloc(
    watchMessages: watchMessages,
    sendMessage: sendMessage,
    sendImageMessage: sendImageMessage,
    editMessage: editMessage,
    deleteMessage: deleteMessage,
  );

  blocTest<ChatBloc, ChatState>(
    'sending a text message shows its own spinner, then clears it on success',
    build: () {
      when(
        () => sendMessage(any()),
      ).thenAnswer((_) async => const Success(null));
      return buildBloc();
    },
    act: (bloc) {
      bloc.add(
        const ChatStarted(currentUserId: 'me', peerId: 'peer'),
      );
      bloc.add(const ChatTextMessageSent('hello'));
    },
    expect: () => [
      const ChatState(submitAction: ChatSubmitAction.sendMessage),
      const ChatState(submitAction: ChatSubmitAction.none),
    ],
  );

  blocTest<ChatBloc, ChatState>(
    'sending a text message shows the error message when it fails',
    build: () {
      when(() => sendMessage(any())).thenAnswer(
        (_) async => const ResultFailure(ServerFailure()),
      );
      return buildBloc();
    },
    act: (bloc) {
      bloc.add(
        const ChatStarted(currentUserId: 'me', peerId: 'peer'),
      );
      bloc.add(const ChatTextMessageSent('hello'));
    },
    expect: () => [
      const ChatState(submitAction: ChatSubmitAction.sendMessage),
      const ChatState(
        submitAction: ChatSubmitAction.none,
        errorMessage: 'Something went wrong on the server. Please try again.',
      ),
    ],
  );
}
