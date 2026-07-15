// This file keep watching login status, so app know if user login or
// not, even after app restart.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase extends StreamUseCase<UserEntity?, NoParams> {
  const WatchAuthStateUseCase(this._authRepository, this._userRepository);

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  @override
  Stream<Result<UserEntity?>> call(NoParams params) {
    return _authRepository.watchAuthState().asyncMap<Result<UserEntity?>>((
      uid,
    ) async {
      if (uid == null) return const Success(null);
      final result = await _userRepository.getUserById(uid);
      return switch (result) {
        Success(:final data) => Success(data),
        ResultFailure(:final failure) => ResultFailure(failure),
      };
    });
  }
}
