import '../repositories/profile_repository.dart';

class SendDeleteAccountOtpUseCase {
  SendDeleteAccountOtpUseCase(this._repository);

  final ProfileRepository _repository;

  Future<String> call() => _repository.sendDeleteAccountOtp();
}
