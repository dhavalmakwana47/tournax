import '../repositories/match_repository.dart';

class DeleteMatchResultsUseCase {
  DeleteMatchResultsUseCase(this._repository);

  final MatchRepository _repository;

  Future<void> call(int matchId) =>
      _repository.deleteMatchResults(matchId);
}
