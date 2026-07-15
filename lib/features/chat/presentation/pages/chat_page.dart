// This is chat screen, where user actually send and see message with
// one other person. It also let user edit or delete his own message.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/dismiss_keyboard.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/delete_message_dialog.dart';
import '../widgets/edit_message_sheet.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.peer});

  final UserEntity peer;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) =>
          sl<ChatBloc>()
            ..add(ChatStarted(currentUserId: currentUserId, peerId: peer.uid)),
      child: _ChatView(peer: peer, currentUserId: currentUserId),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.peer, required this.currentUserId});

  final UserEntity peer;
  final String currentUserId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  void _editMessage(MessageEntity message) {
    final chatBloc = context.read<ChatBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: chatBloc,
        child: EditMessageSheet(
          messageId: message.id,
          initialText: message.text,
        ),
      ),
    );
  }

  void _deleteMessage(MessageEntity message) {
    final chatBloc = context.read<ChatBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: chatBloc,
        child: DeleteMessageDialog(messageId: message.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 40,
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(
                  widget.peer.name.isNotEmpty
                      ? widget.peer.name[0].toUpperCase()
                      : '?',
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(widget.peer.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listenWhen: (previous, current) =>
                    previous.errorMessage != current.errorMessage &&
                    current.errorMessage != null,
                listener: (context, state) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  context.read<ChatBloc>().add(const ChatErrorDismissed());
                },
                builder: (context, state) {
                  switch (state.status) {
                    case ChatStatus.loading:
                      return const LoadingIndicator();
                    case ChatStatus.error:
                      return ErrorView(
                        message: state.errorMessage ?? 'Something went wrong.',
                        onRetry: () => context.read<ChatBloc>().add(
                          ChatStarted(
                            currentUserId: widget.currentUserId,
                            peerId: widget.peer.uid,
                          ),
                        ),
                      );
                    case ChatStatus.loaded:
                      if (state.messages.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.chat_bubble_outline,
                          message: 'No messages yet.\nSay hi 👋',
                        );
                      }
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              state.messages[state.messages.length - 1 - index];
                          final isMe = message.senderId == widget.currentUserId;
                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            onEdit: () => _editMessage(message),
                            onDelete: () => _deleteMessage(message),
                          );
                        },
                      );
                  }
                },
              ),
            ),
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) =>
                  previous.isSending != current.isSending,
              builder: (context, state) {
                return ChatInputBar(
                  isSending: state.isSending,
                  onSendText: (text) =>
                      context.read<ChatBloc>().add(ChatTextMessageSent(text)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
