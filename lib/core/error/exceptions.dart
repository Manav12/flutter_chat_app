// Data source file throw these when something break, like server or
// cache or login problem. Repository catch it and change into Failure.
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
