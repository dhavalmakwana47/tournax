import '../entities/player_entity.dart';
import '../repositories/team_repository.dart';

class UpdatePlayerUseCase {
  UpdatePlayerUseCase(this._repository);

  final TeamRepository _repository;

  Future<PlayerEntity> call({
    required int tournamentId,
    required int teamId,
    required int playerId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) =>
      _repository.updatePlayer(
        tournamentId: tournamentId,
        teamId: teamId,
        playerId: playerId,
        name: name,
        gameUid: gameUid,
        role: role,
        userId: userId,
      );
}
