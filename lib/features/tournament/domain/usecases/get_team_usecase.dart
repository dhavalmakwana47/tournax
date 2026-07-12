import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class GetTeamUseCase {
  GetTeamUseCase(this._repository);

  final TeamRepository _repository;

  Future<TeamEntity> call({
    required int tournamentId,
    required int teamId,
  }) =>
      _repository.getTeam(tournamentId: tournamentId, teamId: teamId);
}
