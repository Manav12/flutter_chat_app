// This file test MessageBubble widget, check sent message go right with
// right color, received message go left with different color, and edit
// option only show for your own message.
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final textMessage = MessageEntity(
    id: 'm1',
    conversationId: 'c1',
    senderId: 'me',
    receiverId: 'peer',
    text: 'Hello there',
    timestamp: DateTime(2024, 1, 1, 10, 30),
  );

  Future<void> pumpBubble(
    WidgetTester tester, {
    required MessageEntity message,
    required bool isMe,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: message,
            isMe: isMe,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('sent message aligns right and uses the sent bubble color', (
    tester,
  ) async {
    await pumpBubble(tester, message: textMessage, isMe: true);

    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, Alignment.centerRight);

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.sentBubble);

    expect(find.text('Hello there'), findsOneWidget);
  });

  testWidgets(
    'received message aligns left and uses the received bubble color',
    (tester) async {
      await pumpBubble(tester, message: textMessage, isMe: false);

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.receivedBubble);
    },
  );

  testWidgets('long-pressing your own text message offers edit and delete', (
    tester,
  ) async {
    await pumpBubble(tester, message: textMessage, isMe: true);

    await tester.longPress(find.byType(GestureDetector));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Edit message'), findsOneWidget);
    expect(find.text('Delete message'), findsOneWidget);
  });

  testWidgets("long-pressing someone else's message does nothing", (
    tester,
  ) async {
    await pumpBubble(tester, message: textMessage, isMe: false);

    await tester.longPress(find.byType(GestureDetector));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Delete message'), findsNothing);
  });
}
