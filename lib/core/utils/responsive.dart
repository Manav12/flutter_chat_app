import 'package:flutter/widgets.dart';

/// This app only runs on phones and tablets, so one width cutoff is all
/// we need to tell "phone" from "tablet".
enum ScreenSize { phone, tablet }

class Responsive {
  const Responsive._();

  static const double tabletBreakpoint = 600;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint ? ScreenSize.tablet : ScreenSize.phone;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;
}
