import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<LoginResult> call({
    required String emailOrUsername,
    required String password,
  }) =>
      _repository.login(emailOrUsername: emailOrUsername, password: password);
}
