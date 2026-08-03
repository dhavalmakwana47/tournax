import '../repositories/player_tournament_repository.dart';

class JoinTournamentUseCase {
  JoinTournamentUseCase(this._repository);

  final PlayerTournamentRepository _repository;

  Future<Map<String, dynamic>> call({
    required int tournamentId,
    required int teamId,
  }) {
    return _repository.joinTournament(
      tournamentId: tournamentId,
      teamId: teamId,
    );
  }
}
