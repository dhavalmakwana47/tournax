import '../entities/match_result_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchResultsUseCase {
  GetMatchResultsUseCase(this._repository);

  final MatchRepository _repository;

  Future<List<TeamResultEntity>> call(int matchId) =>
      _repository.getMatchResults(matchId);
}
