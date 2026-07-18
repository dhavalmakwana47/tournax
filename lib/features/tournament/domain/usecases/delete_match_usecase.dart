import '../repositories/match_repository.dart';

class DeleteMatchUseCase {
  DeleteMatchUseCase(this._repository);
  final MatchRepository _repository;
  Future<void> call(int matchId) => _repository.deleteMatch(matchId);
}
