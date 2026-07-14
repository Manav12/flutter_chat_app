import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

/// Creates the account, then saves that person's profile to Firestore.
/// From outside this class, it just looks like one single step.
class RegisterUseCase extends UseCase<UserEntity, RegisterParams> {
  const RegisterUseCase(this._authRepository, this._userRepository);

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity>> call(RegisterParams params) async {
    final signUpResult = await _authRepository.signUp(
      email: params.email,
      password: params.password,
    );

    return signUpResult.fold((failure) async => ResultFailure(failure), (
      uid,
    ) async {
      final user = UserEntity(
        uid: uid,
        name: params.name,
        email: params.email,
        createdAt: DateTime.now(),
      );
      final createResult = await _userRepository.createUserProfile(user);
      return createResult.fold(
        (failure) => ResultFailure(failure),
        (_) => Success(user),
      );
    });
  }
}
