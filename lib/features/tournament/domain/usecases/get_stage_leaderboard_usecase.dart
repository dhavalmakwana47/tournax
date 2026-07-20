import '../entities/leaderboard_item_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetStageLeaderboardUseCase {
  GetStageLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardItemEntity>> call(int stageId) =>
      _repository.getStageLeaderboard(stageId);
}
