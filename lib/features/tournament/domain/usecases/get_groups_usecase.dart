import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class GetGroupsUseCase {
  GetGroupsUseCase(this._repository);

  final GroupRepository _repository;

  Future<List<GroupEntity>> call(int roundId) =>
      _repository.getGroups(roundId);
}
