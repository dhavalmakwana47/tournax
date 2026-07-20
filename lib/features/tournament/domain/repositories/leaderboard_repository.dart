import '../entities/leaderboard_item_entity.dart';

abstract interface class LeaderboardRepository {
  Future<List<LeaderboardItemEntity>> getGroupLeaderboard(int groupId);
  Future<List<LeaderboardItemEntity>> getRoundLeaderboard(int roundId);
  Future<List<LeaderboardItemEntity>> getStageLeaderboard(int stageId);
  Future<List<LeaderboardItemEntity>> getTournamentLeaderboard(int tournamentId);
  Future<List<LeaderboardItemEntity>> getMatchLeaderboard(int matchId);
}
