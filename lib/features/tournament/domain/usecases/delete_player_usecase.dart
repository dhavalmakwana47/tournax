import '../repositories/team_repository.dart';

class DeletePlayerUseCase {
  DeletePlayerUseCase(this._repository);

  final TeamRepository _repository;

  Future<void> call({
    required int tournamentId,
    required int teamId,
    required int playerId,
  }) =>
      _repository.deletePlayer(
        tournamentId: tournamentId,
        teamId: teamId,
        playerId: playerId,
      );
}
