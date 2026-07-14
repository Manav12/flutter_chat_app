import 'package:equatable/equatable.dart';

enum MessageType { text, image }

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timestamp,
    this.mediaUrl,
    this.editedAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final String? mediaUrl;
  final DateTime? editedAt;

  bool get isEdited => editedAt != null;

  MessageEntity copyWith({String? text, DateTime? editedAt}) {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      text: text ?? this.text,
      type: type,
      timestamp: timestamp,
      mediaUrl: mediaUrl,
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
    type,
    timestamp,
    mediaUrl,
    editedAt,
  ];
}
