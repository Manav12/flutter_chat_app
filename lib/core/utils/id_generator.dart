// This file make unique id for new message or user, right on phone,
// before saving to Firestore.
import 'dart:math';

class IdGenerator {
  const IdGenerator._();

  static final Random _random = Random();

  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomSuffix = _random.nextInt(1 << 32);
    return '$timestamp$randomSuffix';
  }
}
