import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class RemoveMatchTeamUseCase {
  RemoveMatchTeamUseCase(this._repository);
  final MatchRepository _repository;
  Future<MatchEntity> call({
    required int matchId,
    required int teamId,
  }) =>
      _repository.removeTeamFromMatch(
        matchId: matchId,
        teamId: teamId,
      );
}
