// This file make sure splash screen stay for minimum time, so it not
// disappear too fast.
import 'dart:async';

import 'package:flutter/foundation.dart';

class MinDelayGate extends ChangeNotifier {
  MinDelayGate(Duration duration) {
    Timer(duration, () {
      _elapsed = true;
      notifyListeners();
    });
  }

  bool _elapsed = false;
  bool get isElapsed => _elapsed;
}
