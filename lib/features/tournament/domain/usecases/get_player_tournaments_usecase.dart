import '../entities/tournament_entity.dart';
import '../repositories/player_tournament_repository.dart';
import '../repositories/tournament_repository.dart';

class GetPlayerTournamentsUseCase {
  GetPlayerTournamentsUseCase(this._repository);

  final PlayerTournamentRepository _repository;

  Future<PaginatedResult<TournamentEntity>> call({
    int page = 1,
    int perPage = 15,
    String? status,
    String? search,
  }) {
    return _repository.getPublicTournaments(
      page: page,
      perPage: perPage,
      status: status,
      search: search,
    );
  }
}
