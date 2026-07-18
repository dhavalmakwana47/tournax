import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class RemoveGroupTeamUseCase {
  RemoveGroupTeamUseCase(this._repository);

  final GroupRepository _repository;

  Future<GroupEntity> call({
    required int groupId,
    required int teamId,
  }) =>
      _repository.removeGroupTeam(
        groupId: groupId,
        teamId: teamId,
      );
}
