import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String role,
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      _repository.register(
        role: role,
        name: name,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
}
