import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class UpdateMatchUseCase {
  UpdateMatchUseCase(this._repository);
  final MatchRepository _repository;
  Future<MatchEntity> call({
    required int matchId,
    int? matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? startedAt,
    String? endedAt,
    String? status,
  }) =>
      _repository.updateMatch(
        matchId: matchId,
        matchNumber: matchNumber,
        name: name,
        map: map,
        scheduledAt: scheduledAt,
        startedAt: startedAt,
        endedAt: endedAt,
        status: status,
      );
}
