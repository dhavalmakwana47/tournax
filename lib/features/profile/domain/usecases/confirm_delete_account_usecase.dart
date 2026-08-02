import '../repositories/profile_repository.dart';

class ConfirmDeleteAccountUseCase {
  ConfirmDeleteAccountUseCase(this._repository);

  final ProfileRepository _repository;

  Future<String> call(String otp) => _repository.confirmDeleteAccount(otp);
}
