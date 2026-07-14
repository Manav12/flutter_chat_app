/// Data sources throw these when something breaks (server, cache, login).
/// The repository catches them and turns them into a Failure, so the rest
/// of the app never has to deal with a raw error.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}
