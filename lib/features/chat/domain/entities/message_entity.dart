// This file describe what one chat message look like, like text, sender,
// time.
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.editedAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final DateTime? editedAt;

  bool get isEdited => editedAt != null;

  MessageEntity copyWith({String? text, DateTime? editedAt}) {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      text: text ?? this.text,
      timestamp: timestamp,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    receiverId,
    text,
    timestamp,
    editedAt,
  ];
}
