import '../repositories/player_tournament_repository.dart';

class LeaveTournamentUseCase {
  LeaveTournamentUseCase(this._repository);

  final PlayerTournamentRepository _repository;

  Future<String> call({
    required int tournamentId,
    required int teamId,
  }) {
    return _repository.leaveTournament(
      tournamentId: tournamentId,
      teamId: teamId,
    );
  }
}
