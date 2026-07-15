// This is home screen bloc. It watch all user and all conversation
// together, and combine them into one list with last message preview.
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../chat/domain/entities/conversation_preview.dart';
import '../../../chat/domain/usecases/watch_conversations_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/watch_all_users_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required WatchAllUsersUseCase watchAllUsers,
    required WatchConversationsUseCase watchConversations,
  }) : _watchAllUsers = watchAllUsers,
       _watchConversations = watchConversations,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeUsersUpdated>(_onUsersUpdated);
    on<HomeConversationsUpdated>(_onConversationsUpdated);
  }

  final WatchAllUsersUseCase _watchAllUsers;
  final WatchConversationsUseCase _watchConversations;

  String? _currentUserId;
  StreamSubscription<dynamic>? _usersSubscription;
  StreamSubscription<dynamic>? _conversationsSubscription;

  Result<List<UserEntity>>? _latestUsersResult;
  Result<List<ConversationPreview>>? _latestConversationsResult;

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    _currentUserId = event.currentUserId;
    emit(const HomeState());
    _subscribe(event.currentUserId);
  }

  void _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) {
    final uid = _currentUserId;
    if (uid == null) return;
    emit(state.copyWith(isRefreshing: true));
    _subscribe(uid);
  }

  void _subscribe(String currentUserId) {
    unawaited(_usersSubscription?.cancel());
    unawaited(_conversationsSubscription?.cancel());

    _usersSubscription = _watchAllUsers(
      WatchAllUsersParams(excludeUid: currentUserId),
    ).listen((result) => add(HomeUsersUpdated(result)));

    _conversationsSubscription = _watchConversations(
      WatchConversationsParams(currentUserId: currentUserId),
    ).listen((result) => add(HomeConversationsUpdated(result)));
  }

  void _onUsersUpdated(HomeUsersUpdated event, Emitter<HomeState> emit) {
    _latestUsersResult = event.result;
    _emitMerged(emit);
  }

  void _onConversationsUpdated(
    HomeConversationsUpdated event,
    Emitter<HomeState> emit,
  ) {
    _latestConversationsResult = event.result;
    _emitMerged(emit);
  }

  void _emitMerged(Emitter<HomeState> emit) {
    final usersResult = _latestUsersResult;
    if (usersResult == null) return;

    usersResult.fold(
      (failure) {
        if (state.items.isEmpty) {
          emit(
            state.copyWith(
              status: HomeStatus.error,
              errorMessage: failure.message,
              isRefreshing: false,
            ),
          );
        } else {
          emit(state.copyWith(isRefreshing: false));
        }
      },
      (users) {
        final conversations = <ConversationPreview>[];
        _latestConversationsResult?.fold(
          (_) {},
          (list) => conversations.addAll(list),
        );

        final byPeerUid = {for (final c in conversations) c.peer.uid: c};
        final items = users.map((user) {
          final convo = byPeerUid[user.uid];
          return HomeListItem(
            user: user,
            lastMessageText: convo?.lastMessageText,
            lastMessageAt: convo?.lastMessageAt,
            lastMessageSenderId: convo?.lastMessageSenderId,
          );
        }).toList();

        items.sort((a, b) {
          if (a.lastMessageAt == null && b.lastMessageAt == null) {
            return a.user.name.toLowerCase().compareTo(
              b.user.name.toLowerCase(),
            );
          }
          if (a.lastMessageAt == null) return 1;
          if (b.lastMessageAt == null) return -1;
          return b.lastMessageAt!.compareTo(a.lastMessageAt!);
        });

        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            items: items,
            isRefreshing: false,
            clearError: true,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    unawaited(_usersSubscription?.cancel());
    unawaited(_conversationsSubscription?.cancel());
    return super.close();
  }
}
