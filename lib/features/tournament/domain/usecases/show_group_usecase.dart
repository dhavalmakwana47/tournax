import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class ShowGroupUseCase {
  ShowGroupUseCase(this._repository);

  final GroupRepository _repository;

  Future<GroupEntity> call(int groupId) => _repository.showGroup(groupId);
}
