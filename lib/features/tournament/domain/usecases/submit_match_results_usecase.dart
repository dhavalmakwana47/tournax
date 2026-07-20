import '../entities/match_result_entity.dart';
import '../repositories/match_repository.dart';

class SubmitMatchResultsUseCase {
  SubmitMatchResultsUseCase(this._repository);

  final MatchRepository _repository;

  Future<void> call({
    required int matchId,
    required List<TeamResultEntity> results,
  }) =>
      _repository.submitMatchResults(matchId: matchId, results: results);
}
