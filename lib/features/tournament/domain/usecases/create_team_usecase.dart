import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class CreateTeamUseCase {
  CreateTeamUseCase(this._repository);

  final TeamRepository _repository;

  Future<TeamEntity> call({
    required int tournamentId,
    required String name,
  }) =>
      _repository.createTeam(tournamentId: tournamentId, name: name);
}
