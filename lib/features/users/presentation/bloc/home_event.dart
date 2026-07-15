// This file list actions for home screen, like start watching users,
// or pull-to-refresh.
import 'package:equatable/equatable.dart';

import '../../../chat/domain/entities/conversation_preview.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted({required this.currentUserId});
  final String currentUserId;
  @override
  List<Object?> get props => [currentUserId];
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomeUsersUpdated extends HomeEvent {
  const HomeUsersUpdated(this.result);
  final Result<List<UserEntity>> result;
  @override
  List<Object?> get props => [result];
}

class HomeConversationsUpdated extends HomeEvent {
  const HomeConversationsUpdated(this.result);
  final Result<List<ConversationPreview>> result;
  @override
  List<Object?> get props => [result];
}
