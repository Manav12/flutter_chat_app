/// Builds one shared chat id from two user ids. Sorting them first means
/// both people always end up with the exact same id, so we never have to
/// search around for "does this chat already exist?".
String buildConversationId(String uidA, String uidB) {
  final sorted = [uidA, uidB]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
