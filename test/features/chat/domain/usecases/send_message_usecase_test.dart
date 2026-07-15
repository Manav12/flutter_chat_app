// This file test SendMessageUseCase, check it build message correctly
// (trim text, derive conversation id) before sending it.
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/utils/conversation_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late SendMessageUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeMessageEntity());
  });

  setUp(() {
    repository = MockChatRepository();
    useCase = SendMessageUseCase(repository);
  });

  test(
    'builds a text message with trimmed text and correct conversation id',
    () async {
      when(
        () => repository.sendMessage(any()),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase(
        const SendMessageParams(
          senderId: 'uidA',
          receiverId: 'uidB',
          text: '  hello  ',
        ),
      );

      expect(result, isA<Success<void>>());
      final captured = verify(
        () => repository.sendMessage(captureAny()),
      ).captured;
      final sentMessage = captured.single as MessageEntity;
      expect(sentMessage.senderId, 'uidA');
      expect(sentMessage.receiverId, 'uidB');
      expect(sentMessage.text, 'hello');
      expect(sentMessage.type, MessageType.text);
      expect(sentMessage.conversationId, buildConversationId('uidA', 'uidB'));
    },
  );
}
