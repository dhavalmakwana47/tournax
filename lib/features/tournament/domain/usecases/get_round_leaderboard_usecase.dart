import '../entities/leaderboard_item_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetRoundLeaderboardUseCase {
  GetRoundLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardItemEntity>> call(int roundId, {int? page, int? perPage}) =>
      _repository.getRoundLeaderboard(roundId, page: page, perPage: perPage);
}
