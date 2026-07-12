import '../repositories/team_repository.dart';

class DeleteTeamUseCase {
  DeleteTeamUseCase(this._repository);

  final TeamRepository _repository;

  Future<void> call({
    required int tournamentId,
    required int teamId,
  }) =>
      _repository.deleteTeam(tournamentId: tournamentId, teamId: teamId);
}
