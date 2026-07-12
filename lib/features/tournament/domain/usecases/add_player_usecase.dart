import '../entities/player_entity.dart';
import '../repositories/team_repository.dart';

class AddPlayerUseCase {
  AddPlayerUseCase(this._repository);

  final TeamRepository _repository;

  Future<PlayerEntity> call({
    required int tournamentId,
    required int teamId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) =>
      _repository.addPlayer(
        tournamentId: tournamentId,
        teamId: teamId,
        name: name,
        gameUid: gameUid,
        role: role,
        userId: userId,
      );
}
