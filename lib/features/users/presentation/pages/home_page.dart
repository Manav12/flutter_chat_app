// This is main page, user come here after login. It show live list of
// all other user, with their last chat message if any, so this user
// can tap on someone and start chatting. Same layout and flow on every
// screen size, phone or tablet.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/double_back_to_exit.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) =>
          sl<HomeBloc>()..add(HomeStarted(currentUserId: currentUserId)),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _onRefresh(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    bloc.add(const HomeRefreshRequested());
    await bloc.stream.firstWhere((s) => !s.isRefreshing);
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthBloc>().state.user?.name ?? '';

    return DoubleBackToExit(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: userName,
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            switch (state.status) {
              case HomeStatus.loading:
                return const LoadingIndicator();
              case HomeStatus.error:
                return ErrorView(
                  message: state.errorMessage ?? 'Something went wrong.',
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeRefreshRequested()),
                );
              case HomeStatus.loaded:
                if (state.items.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.people_outline,
                    message: 'No other users yet.\nInvite someone to join!',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _UserListTile(item: item);
                    },
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  const _UserListTile({required this.item});

  final HomeListItem item;

  @override
  Widget build(BuildContext context) {
    final user = item.user;
    final currentUserId = context.read<AuthBloc>().state.user?.uid;
    final theme = Theme.of(context);

    final String subtitle;
    if (!item.hasConversation) {
      subtitle = 'Say hi 👋';
    } else if (item.lastMessageSenderId == currentUserId) {
      subtitle = 'You: ${item.lastMessageText}';
    } else {
      subtitle = item.lastMessageText ?? '';
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: item.hasConversation
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormatting.chatListTimestamp(item.lastMessageAt!),
                  style: theme.textTheme.bodySmall,
                ),
                if (item.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  _UnreadBadge(count: item.unreadCount),
                ],
              ],
            )
          : null,
      onTap: () => context.push('/chat/${user.uid}', extra: user),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
