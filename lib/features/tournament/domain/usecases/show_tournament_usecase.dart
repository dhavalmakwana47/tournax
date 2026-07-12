import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class ShowTournamentUseCase {
  ShowTournamentUseCase(this._repository);

  final TournamentRepository _repository;

  Future<TournamentEntity> call(int tournamentId) =>
      _repository.showTournament(tournamentId);
}
