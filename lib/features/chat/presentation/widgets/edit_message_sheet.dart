// This is popup box for editing a message text, opened by long-press
// on your own message.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/bottom_sheet_handle.dart';
import '../../../../core/widgets/dismiss_keyboard.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class EditMessageSheet extends StatefulWidget {
  const EditMessageSheet({
    super.key,
    required this.messageId,
    required this.initialText,
  });

  final String messageId;
  final String initialText;

  @override
  State<EditMessageSheet> createState() => _EditMessageSheetState();
}

class _EditMessageSheetState extends State<EditMessageSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final text = _controller.text.trim();
    if (text.isEmpty || text == widget.initialText) {
      Navigator.of(context).pop();
      return;
    }
    context.read<ChatBloc>().add(
      ChatMessageEditRequested(messageId: widget.messageId, newText: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.submitAction == ChatSubmitAction.editMessage &&
          current.submitAction == ChatSubmitAction.none &&
          current.errorMessage == null,
      listener: (context, state) => Navigator.of(context).pop(),
      child: DismissKeyboard(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BottomSheetHandle(),
              Text(
                'Edit message',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _controller,
                label: 'Message',
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'Save',
                    isLoading: state.isEditingMessage,
                    onPressed: state.isEditingMessage ? null : _save,
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
