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
    required super.type,
    required super.timestamp,
    super.mediaUrl,
    super.editedAt,
  });

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
    id: entity.id,
    conversationId: entity.conversationId,
    senderId: entity.senderId,
    receiverId: entity.receiverId,
    text: entity.text,
    type: entity.type,
    timestamp: entity.timestamp,
    mediaUrl: entity.mediaUrl,
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
      type: MessageType.values.firstWhere(
        (value) => value.name == json['type']?.toString(),
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] is int
            ? json['timestamp'] as int
            : int.tryParse(json['timestamp']?.toString() ?? '') ?? 0,
      ),
      mediaUrl: json['mediaUrl']?.toString(),
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
    'type': type.name,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'mediaUrl': mediaUrl,
    'editedAt': editedAt?.millisecondsSinceEpoch,
  };
}
