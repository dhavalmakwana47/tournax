import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/leaderboard_item_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasource/leaderboard_remote_datasource.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final LeaderboardRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<LeaderboardItemEntity>> getGroupLeaderboard(int groupId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getGroupLeaderboard(groupId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getRoundLeaderboard(int roundId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getRoundLeaderboard(roundId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getStageLeaderboard(int stageId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getStageLeaderboard(stageId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getTournamentLeaderboard(int tournamentId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getTournamentLeaderboard(tournamentId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getMatchLeaderboard(int matchId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getMatchLeaderboard(matchId);
    return models.map((m) => m.toEntity()).toList();
  }
}
