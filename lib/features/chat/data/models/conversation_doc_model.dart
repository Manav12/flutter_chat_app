// This file describe small summary doc for one chat, like who is in
// chat and what was last message. We need this because otherwise, to
// show last message preview on home screen, app would have to open
// every single chat and read all its message, which is very slow. So
// instead we keep one small summary doc per chat, updated every time
// new message send, and home screen just read this small doc.
class ConversationDocModel {
  const ConversationDocModel({
    required this.conversationId,
    required this.participantIds,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
  });

  final String conversationId;
  final List<String> participantIds;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;

  String peerIdFor(String currentUserId) =>
      participantIds.firstWhere((id) => id != currentUserId);

  factory ConversationDocModel.fromJson(
    String conversationId,
    Map<String, dynamic> json,
  ) {
    return ConversationDocModel(
      conversationId: conversationId,
      participantIds: List<String>.from(
        json['participantIds'] as List? ?? const [],
      ),
      lastMessageText: json['lastMessageText']?.toString(),
      lastMessageSenderId: json['lastMessageSenderId']?.toString(),
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              json['lastMessageAt'] as int,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'participantIds': participantIds,
    'lastMessageText': lastMessageText,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageAt': lastMessageAt?.millisecondsSinceEpoch,
  };
}
