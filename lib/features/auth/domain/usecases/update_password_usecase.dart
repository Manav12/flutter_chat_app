// This file handle change password step.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordParams {
  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

class UpdatePasswordUseCase extends UseCase<void, UpdatePasswordParams> {
  const UpdatePasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(UpdatePasswordParams params) {
    return _repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
