// This widget stop app closing on one back press. User need to press
// back two time to actually exit app.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
    this.window = const Duration(seconds: 2),
  });

  final Widget child;
  final String message;
  final Duration window;

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPressAt;

  void _handleBackPress() {
    final now = DateTime.now();
    final pressedAgainInTime =
        _lastBackPressAt != null &&
        now.difference(_lastBackPressAt!) < widget.window;

    if (pressedAgainInTime) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressAt = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(widget.message), duration: widget.window),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: widget.child,
    );
  }
}
