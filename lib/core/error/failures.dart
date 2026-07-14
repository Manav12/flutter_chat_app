import 'package:equatable/equatable.dart';

/// This is what we hand back when something goes wrong, instead of
/// throwing an error. It's Equatable so tests can compare two Failures
/// and know if they're the same.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on the server. Please try again.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and retry.',
  ]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request timed out. Please try again.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
