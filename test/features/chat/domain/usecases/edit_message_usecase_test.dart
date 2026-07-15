// This file test EditMessageUseCase, check it derive conversation id and
// trim new text before asking repository to edit the message.
import 'package:flutter_chat_app/core/utils/result.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/edit_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/utils/conversation_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late EditMessageUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = EditMessageUseCase(repository);
  });

  test('derives conversation id and trims new text before editing', () async {
    when(
      () => repository.editMessage(
        conversationId: any(named: 'conversationId'),
        messageId: any(named: 'messageId'),
        newText: any(named: 'newText'),
      ),
    ).thenAnswer((_) async => const Success(null));

    final result = await useCase(
      const EditMessageParams(
        currentUserId: 'uidA',
        peerId: 'uidB',
        messageId: 'msg1',
        newText: '  updated text  ',
      ),
    );

    expect(result, isA<Success<void>>());
    verify(
      () => repository.editMessage(
        conversationId: buildConversationId('uidA', 'uidB'),
        messageId: 'msg1',
        newText: 'updated text',
      ),
    ).called(1);
  });
}
