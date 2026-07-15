// This is confirm popup shown before deleting a message, opened by
// long-press on your own message.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class DeleteMessageDialog extends StatelessWidget {
  const DeleteMessageDialog({super.key, required this.messageId});

  final String messageId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.submitAction == ChatSubmitAction.deleteMessage &&
          current.submitAction == ChatSubmitAction.none &&
          current.errorMessage == null,
      listener: (context, state) => Navigator.of(context).pop(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.errorContainer,
                child: Icon(
                  Icons.delete_outline,
                  size: 28,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete message?',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "This can't be undone.",
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.outline),
                          ),
                          onPressed: state.isDeletingMessage
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                          ),
                          onPressed: state.isDeletingMessage
                              ? null
                              : () => context.read<ChatBloc>().add(
                                  ChatMessageDeleteRequested(messageId),
                                ),
                          child: state.isDeletingMessage
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Delete'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
