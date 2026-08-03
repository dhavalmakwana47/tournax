import '../entities/tournament_entity.dart';
import '../repositories/player_tournament_repository.dart';
import '../repositories/tournament_repository.dart';

class GetParticipatedTournamentsUseCase {
  GetParticipatedTournamentsUseCase(this._repository);

  final PlayerTournamentRepository _repository;

  Future<PaginatedResult<TournamentEntity>> call({
    int page = 1,
    int perPage = 15,
    String? status,
  }) {
    return _repository.getParticipatedTournaments(
      page: page,
      perPage: perPage,
      status: status,
    );
  }
}
