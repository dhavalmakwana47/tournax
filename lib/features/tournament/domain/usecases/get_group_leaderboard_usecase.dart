import '../entities/leaderboard_item_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetGroupLeaderboardUseCase {
  GetGroupLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<List<LeaderboardItemEntity>> call(int groupId, {int? page, int? perPage}) =>
      _repository.getGroupLeaderboard(groupId, page: page, perPage: perPage);
}
