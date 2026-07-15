// This file handle login step, sign in then get full user profile back.
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  const LoginUseCase(this._authRepository, this._userRepository);

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity>> call(LoginParams params) async {
    final signInResult = await _authRepository.signIn(
      email: params.email,
      password: params.password,
    );
    return signInResult.fold(
      (failure) async => ResultFailure(failure),
      (uid) => _userRepository.getUserById(uid),
    );
  }
}
