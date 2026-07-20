import '../entities/leaderboard_item_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetMatchLeaderboardUseCase {
  GetMatchLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardItemEntity>> call(int matchId) =>
      _repository.getMatchLeaderboard(matchId);
}
