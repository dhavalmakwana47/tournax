import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class UpdateMatchSlotsUseCase {
  UpdateMatchSlotsUseCase(this._repository);
  final MatchRepository _repository;

  Future<MatchEntity> call({
    required int matchId,
    required List<Map<String, dynamic>> slots,
  }) =>
      _repository.updateMatchSlots(
        matchId: matchId,
        slots: slots,
      );
}
