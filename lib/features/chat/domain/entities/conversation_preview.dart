// This file describe one row on home screen list, other person plus
// last message.
import 'package:equatable/equatable.dart';

import '../../../users/domain/entities/user_entity.dart';

class ConversationPreview extends Equatable {
  const ConversationPreview({
    required this.peer,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageSenderId,
  });

  final UserEntity peer;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;

  bool get hasConversation => lastMessageAt != null;

  @override
  List<Object?> get props => [
    peer,
    lastMessageText,
    lastMessageAt,
    lastMessageSenderId,
  ];
}
