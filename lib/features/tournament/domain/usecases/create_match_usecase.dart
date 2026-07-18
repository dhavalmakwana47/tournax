import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class CreateMatchUseCase {
  CreateMatchUseCase(this._repository);
  final MatchRepository _repository;
  Future<MatchEntity> call({
    required int groupId,
    required int matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? status,
  }) =>
      _repository.createMatch(
        groupId: groupId,
        matchNumber: matchNumber,
        name: name,
        map: map,
        scheduledAt: scheduledAt,
        status: status,
      );
}
