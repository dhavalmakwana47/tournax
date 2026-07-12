import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class UpdateTeamUseCase {
  UpdateTeamUseCase(this._repository);

  final TeamRepository _repository;

  Future<TeamEntity> call({
    required int tournamentId,
    required int teamId,
    required String name,
  }) =>
      _repository.updateTeam(
        tournamentId: tournamentId,
        teamId: teamId,
        name: name,
      );
}
