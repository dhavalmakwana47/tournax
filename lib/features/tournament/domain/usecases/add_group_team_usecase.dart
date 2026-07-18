import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class AddGroupTeamUseCase {
  AddGroupTeamUseCase(this._repository);

  final GroupRepository _repository;

  Future<GroupEntity> call({
    required int groupId,
    required int teamId,
    int? seed,
  }) =>
      _repository.addGroupTeam(
        groupId: groupId,
        teamId: teamId,
        seed: seed,
      );
}
