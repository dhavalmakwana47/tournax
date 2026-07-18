import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class AddMatchTeamUseCase {
  AddMatchTeamUseCase(this._repository);
  final MatchRepository _repository;
  Future<MatchEntity> call({
    required int matchId,
    required int teamId,
    int? slot,
    String? lane,
  }) =>
      _repository.addTeamToMatch(
        matchId: matchId,
        teamId: teamId,
        slot: slot,
        lane: lane,
      );
}
