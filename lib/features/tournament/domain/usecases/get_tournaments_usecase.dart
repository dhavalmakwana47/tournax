import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

class GetTournamentsUseCase {
  GetTournamentsUseCase(this._repository);

  final TournamentRepository _repository;

  Future<List<TournamentEntity>> call() => _repository.getTournaments();
}
