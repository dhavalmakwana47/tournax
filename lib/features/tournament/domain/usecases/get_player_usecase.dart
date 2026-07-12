import '../entities/player_entity.dart';
import '../repositories/team_repository.dart';

class GetPlayerUseCase {
  GetPlayerUseCase(this._repository);

  final TeamRepository _repository;

  Future<PlayerEntity> call({
    required int tournamentId,
    required int teamId,
    required int playerId,
  }) =>
      _repository.getPlayer(
        tournamentId: tournamentId,
        teamId: teamId,
        playerId: playerId,
      );
}
