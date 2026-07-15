// This file check screen width, so app know phone is normal phone or
// tablet.
import 'package:flutter/widgets.dart';

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
