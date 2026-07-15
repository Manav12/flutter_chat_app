// This file describe home screen state, like list of user with their
// last message, loading, error.
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

enum HomeStatus { loading, loaded, error }

class HomeListItem extends Equatable {
  const HomeListItem({
    required this.user,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = 1,
  });

  final UserEntity user;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadCount;

  bool get hasConversation => lastMessageAt != null;

  @override
  List<Object?> get props => [
    user,
    lastMessageText,
    lastMessageAt,
    lastMessageSenderId,
    unreadCount,
  ];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.items = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  final HomeStatus status;
  final List<HomeListItem> items;
  final String? errorMessage;
  final bool isRefreshing;

  HomeState copyWith({
    HomeStatus? status,
    List<HomeListItem>? items,
    String? errorMessage,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, isRefreshing];
}
