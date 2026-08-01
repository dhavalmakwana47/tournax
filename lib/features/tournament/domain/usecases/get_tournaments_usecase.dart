import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentsUseCase {
  GetTournamentsUseCase(this._repository);

  final TournamentRepository _repository;

  Future<PaginatedResult<TournamentEntity>> call({
    int page = 1,
    int perPage = 5,
    String? status,
  }) =>
      _repository.getTournaments(page: page, perPage: perPage, status: status);
}
