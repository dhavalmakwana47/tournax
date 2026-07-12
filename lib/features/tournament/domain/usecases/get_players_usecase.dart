import '../entities/player_entity.dart';
import '../repositories/team_repository.dart';

class GetPlayersUseCase {
  GetPlayersUseCase(this._repository);

  final TeamRepository _repository;

  Future<List<PlayerEntity>> call({
    required int tournamentId,
    required int teamId,
  }) =>
      _repository.getPlayers(tournamentId: tournamentId, teamId: teamId);
}
