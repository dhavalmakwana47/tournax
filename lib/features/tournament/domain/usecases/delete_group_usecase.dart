import '../repositories/group_repository.dart';

class DeleteGroupUseCase {
  DeleteGroupUseCase(this._repository);

  final GroupRepository _repository;

  Future<void> call(int groupId) => _repository.deleteGroup(groupId);
}
