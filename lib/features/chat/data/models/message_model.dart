// This file change message data to JSON and back, so we can save and
// load it from Firestore or Hive.
import 'dart:convert';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.receiverId,
    required super.text,
    required super.timestamp,
    super.editedAt,
  });

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
    id: entity.id,
    conversationId: entity.conversationId,
    senderId: entity.senderId,
    receiverId: entity.receiverId,
    text: entity.text,
    timestamp: entity.timestamp,
    editedAt: entity.editedAt,
  );

  factory MessageModel.fromRawJson(String str) =>
      MessageModel.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] is int
            ? json['timestamp'] as int
            : int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
      ),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              json['editedAt'] is int
                  ? json['editedAt'] as int
                  : int.tryParse(json['editedAt'].toString()) ?? 0,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'editedAt': editedAt?.millisecondsSinceEpoch,
  };
}
