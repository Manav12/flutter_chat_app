// This file decide where chat data come from, online or cache, and
// also join chat summary with user profile for home screen list.
import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/entities/conversation_preview.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required ChatLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required UserRepository userRepository,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _userRepository = userRepository;

  final ChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final UserRepository _userRepository;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<Result<void>> sendMessage(MessageEntity message) async {
    try {
      await _remoteDataSource
          .sendMessage(MessageModel.fromEntity(message))
          .timeout(_timeout);
      return const Success(null);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Stream<Result<List<MessageEntity>>> watchMessages(
    String conversationId,
  ) async* {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      yield* _cachedMessages(conversationId);
      return;
    }

    try {
      await for (final messages in _remoteDataSource.watchMessages(
        conversationId,
      )) {
        unawaited(_localDataSource.cacheMessages(conversationId, messages));
        yield Success<List<MessageEntity>>(messages);
      }
    } catch (_) {
      yield* _cachedMessages(conversationId);
    }
  }

  Stream<Result<List<MessageEntity>>> _cachedMessages(
    String conversationId,
  ) async* {
    try {
      final cached = await _localDataSource.getCachedMessages(conversationId);
      yield Success<List<MessageEntity>>(cached);
    } on CacheException {
      yield const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<void>> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    try {
      await _remoteDataSource
          .editMessage(
            conversationId: conversationId,
            messageId: messageId,
            newText: newText,
          )
          .timeout(_timeout);
      return const Success(null);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    try {
      await _remoteDataSource
          .deleteMessage(conversationId: conversationId, messageId: messageId)
          .timeout(_timeout);
      return const Success(null);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }

  @override
  Stream<Result<List<ConversationPreview>>> watchConversations(
    String currentUserId,
  ) async* {
    try {
      await for (final docs in _remoteDataSource.watchConversations(
        currentUserId,
      )) {
        final previews = <ConversationPreview>[];
        for (final doc in docs) {
          final peerId = doc.peerIdFor(currentUserId);
          final peerResult = await _userRepository.getUserById(peerId);
          peerResult.fold(
            (_) {},
            (peer) => previews.add(
              ConversationPreview(
                peer: peer,
                lastMessageText: doc.lastMessageText,
                lastMessageAt: doc.lastMessageAt,
                lastMessageSenderId: doc.lastMessageSenderId,
              ),
            ),
          );
        }
        previews.sort(
          (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
            a.lastMessageAt ?? DateTime(0),
          ),
        );
        yield Success(previews);
      }
    } catch (_) {
      yield const ResultFailure(NetworkFailure());
    }
  }

  @override
  Future<Result<String>> uploadChatImage({
    required String conversationId,
    required String localFilePath,
  }) async {
    try {
      final url = await _remoteDataSource
          .uploadChatImage(
            conversationId: conversationId,
            localFilePath: localFilePath,
          )
          .timeout(_timeout);
      return Success(url);
    } on TimeoutException {
      return const ResultFailure(TimeoutFailure());
    } catch (_) {
      return const ResultFailure(ServerFailure());
    }
  }
}
