// This file make one chat id from two user id. We sort both id first,
// so it don't matter who open chat first, both user always get exact
// same id for their conversation. This help us find same chat again
// without searching whole database.
String buildConversationId(String uidA, String uidB) {
  final sorted = [uidA, uidB]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
