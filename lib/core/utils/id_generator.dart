import 'dart:math';

/// Makes up a unique id for a new message or user, right here on the
/// phone, before it's ever saved to Firestore. That way we already have
/// an id to work with, even before the server gives us one.
class IdGenerator {
  const IdGenerator._();

  static final Random _random = Random();

  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomSuffix = _random.nextInt(1 << 32);
    return '$timestamp$randomSuffix';
  }
}
