// This is real chat system, using Firestore "chats" collection for
// message. It do exact same job as the fake version, just talk to real
// Firebase instead of memory.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/conversation_doc_model.dart';
import '../models/message_model.dart';
import 'chat_remote_data_source.dart';

class FirebaseChatRemoteDataSource implements ChatRemoteDataSource {
  FirebaseChatRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _chatDoc(String conversationId) =>
      _firestore.collection('chats').doc(conversationId);

  CollectionReference<Map<String, dynamic>> _messagesCollection(
    String conversationId,
  ) => _chatDoc(conversationId).collection('messages');

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        _messagesCollection(message.conversationId).doc(message.id),
        message.toJson(),
      );
      batch.set(_chatDoc(message.conversationId), {
        'participantIds': [message.senderId, message.receiverId],
        'lastMessageText': message.text,
        'lastMessageSenderId': message.senderId,
        'lastMessageAt': message.timestamp.millisecondsSinceEpoch,
      }, SetOptions(merge: true));
      await batch.commit();
      // set(merge: true) treats dotted keys as literal field names, not
      // nested paths, so the unread counter needs a real update() call —
      // only update() parses "unreadCounts.<uid>" into a nested path.
      await _chatDoc(message.conversationId).update({
        'unreadCounts.${message.receiverId}': FieldValue.increment(1),
      });
    } catch (_) {
      throw const ServerException('Could not send message.');
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _messagesCollection(conversationId)
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    try {
      await _messagesCollection(conversationId).doc(messageId).update({
        'text': newText,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      });
      await _refreshLastMessage(conversationId);
    } catch (_) {
      throw const ServerException('Could not edit message.');
    }
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await _messagesCollection(conversationId).doc(messageId).delete();
      await _refreshLastMessage(conversationId);
    } catch (_) {
      throw const ServerException('Could not delete message.');
    }
  }

  Future<void> _refreshLastMessage(String conversationId) async {
    final latest = await _messagesCollection(
      conversationId,
    ).orderBy('timestamp', descending: true).limit(1).get();

    if (latest.docs.isEmpty) {
      await _chatDoc(conversationId).set({
        'lastMessageText': null,
        'lastMessageSenderId': null,
        'lastMessageAt': null,
      }, SetOptions(merge: true));
      return;
    }

    final last = MessageModel.fromJson(latest.docs.first.data());
    await _chatDoc(conversationId).set({
      'lastMessageText': last.text,
      'lastMessageSenderId': last.senderId,
      'lastMessageAt': last.timestamp.millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markConversationRead({
    required String conversationId,
    required String currentUserId,
    required String peerId,
  }) async {
    try {
      final doc = _chatDoc(conversationId);
      await doc.set({
        'participantIds': [currentUserId, peerId],
      }, SetOptions(merge: true));
      await doc.update({'unreadCounts.$currentUserId': 0});
    } catch (_) {
      throw const ServerException('Could not update read status.');
    }
  }

  @override
  Stream<List<ConversationDocModel>> watchConversations(
    String currentUserId,
  ) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConversationDocModel.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }
}
