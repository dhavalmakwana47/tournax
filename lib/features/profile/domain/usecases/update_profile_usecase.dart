import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({String? name, String? email, String? username}) =>
      _repository.updateProfile(name: name, email: email, username: username);
}
