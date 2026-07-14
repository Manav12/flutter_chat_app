import '../error/failures.dart';

/// A simple box that holds either "it worked" (Success) or "it failed"
/// (ResultFailure). Instead of throwing errors everywhere, functions just
/// hand back one of these, and we check which one it is.

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      ResultFailure(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
