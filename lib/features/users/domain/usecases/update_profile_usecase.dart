// This file save updated profile, like new name.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase extends UseCase<void, UserEntity> {
  const UpdateProfileUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<void>> call(UserEntity params) {
    return _repository.updateProfile(params);
  }
}
