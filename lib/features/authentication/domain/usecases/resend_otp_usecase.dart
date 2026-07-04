import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) => _repository.resendEmailOtp(email);
}
