import '../entities/leaderboard_item_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetRoundLeaderboardUseCase {
  GetRoundLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardItemEntity>> call(int roundId) =>
      _repository.getRoundLeaderboard(roundId);
}
