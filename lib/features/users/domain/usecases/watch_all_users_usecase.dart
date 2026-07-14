import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class WatchAllUsersParams {
  const WatchAllUsersParams({required this.excludeUid});
  final String excludeUid;
}

class WatchAllUsersUseCase
    extends StreamUseCase<List<UserEntity>, WatchAllUsersParams> {
  const WatchAllUsersUseCase(this._repository);

  final UserRepository _repository;

  @override
  Stream<Result<List<UserEntity>>> call(WatchAllUsersParams params) {
    return _repository.watchAllUsers(excludeUid: params.excludeUid);
  }
}
