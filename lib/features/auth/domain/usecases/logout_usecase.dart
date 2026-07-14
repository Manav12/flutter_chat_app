import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.signOut();
  }
}
