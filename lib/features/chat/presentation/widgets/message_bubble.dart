// This widget draw one chat message bubble. Sent message align right in
// blue, received message align left in grey. Long-press own message to
// edit or delete it.
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/bottom_sheet_handle.dart';
import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onEdit,
    required this.onDelete,
  });

  final MessageEntity message;
  final bool isMe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  void _showActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canEditThisMessage = message.type == MessageType.text;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetHandle(),
              if (canEditThisMessage)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.edit_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Edit message'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onEdit();
                  },
                ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.errorContainer,
                  child: Icon(
                    Icons.delete_outline,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                title: Text(
                  'Delete message',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppColors.sentBubble : AppColors.receivedBubble;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () => _showActions(context) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 2),
              bottomRight: Radius.circular(isMe ? 2 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.type == MessageType.image &&
                  message.mediaUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _MessageImage(path: message.mediaUrl!),
                )
              else
                Text(message.text, style: TextStyle(color: textColor)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isEdited)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        'edited',
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  Text(
                    DateFormatting.messageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageImage extends StatelessWidget {
  const _MessageImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final isRemote = path.startsWith('http');
    final errorIcon = const Icon(Icons.broken_image_outlined);
    return SizedBox(
      width: 200,
      height: 200,
      child: isRemote
          ? Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => errorIcon,
            )
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => errorIcon,
            ),
    );
  }
}
