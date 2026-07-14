import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF3D5AFE);
  static const Color secondary = Color(0xFF00BFA5);

  // Bubble colors are kept separate from the app's theme colors so a
  // "sent" bubble always looks different from a "received" one, in both
  // light and dark mode.
  static const Color sentBubbleLight = primary;
  static const Color sentBubbleDark = Color(0xFF5C7CFA);
  static const Color receivedBubbleLight = Color(0xFFEFEFF4);
  static const Color receivedBubbleDark = Color(0xFF2C2C2E);
}
