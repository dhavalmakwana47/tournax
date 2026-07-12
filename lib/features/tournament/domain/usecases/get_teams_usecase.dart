import '../entities/team_entity.dart';
import '../repositories/team_repository.dart';

class GetTeamsUseCase {
  GetTeamsUseCase(this._repository);

  final TeamRepository _repository;

  Future<List<TeamEntity>> call(int tournamentId) =>
      _repository.getTeams(tournamentId);
}
