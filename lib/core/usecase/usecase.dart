import '../utils/result.dart';

/// Something that runs once and gives back one answer — like logging in,
/// sending a message, or deleting one.
abstract class UseCase<ReturnType, Params> {
  const UseCase();
  Future<Result<ReturnType>> call(Params params);
}

/// Something that keeps watching and sends updates over time — like
/// listening for new chat messages as they arrive.
abstract class StreamUseCase<ReturnType, Params> {
  const StreamUseCase();
  Stream<Result<ReturnType>> call(Params params);
}

/// Use this when a use case doesn't need any input to run.
final class NoParams {
  const NoParams();
}
