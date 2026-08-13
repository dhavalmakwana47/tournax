import '../entities/leaderboard_item_entity.dart';

abstract interface class LeaderboardRepository {
  Future<List<LeaderboardItemEntity>> getGroupLeaderboard(int groupId, {int? page, int? perPage});
  Future<List<LeaderboardItemEntity>> getRoundLeaderboard(int roundId, {int? page, int? perPage});
  Future<List<LeaderboardItemEntity>> getStageLeaderboard(int stageId, {int? page, int? perPage});
  Future<List<LeaderboardItemEntity>> getTournamentLeaderboard(int tournamentId, {int? page, int? perPage});
  Future<List<LeaderboardItemEntity>> getMatchLeaderboard(int matchId, {int? page, int? perPage});
}
