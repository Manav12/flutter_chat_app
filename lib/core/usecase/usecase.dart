// These are base class for use case. One type run once (like login),
// other type keep watching and give update (like new chat message).
import '../utils/result.dart';

abstract class UseCase<ReturnType, Params> {
  const UseCase();
  Future<Result<ReturnType>> call(Params params);
}

abstract class StreamUseCase<ReturnType, Params> {
  const StreamUseCase();
  Stream<Result<ReturnType>> call(Params params);
}

final class NoParams {
  const NoParams();
}
