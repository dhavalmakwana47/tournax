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
  Future<List<LeaderboardItemEntity>> getGroupLeaderboard(int groupId, {int? page, int? perPage}) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getGroupLeaderboard(groupId, page: page, perPage: perPage);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getRoundLeaderboard(int roundId, {int? page, int? perPage}) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getRoundLeaderboard(roundId, page: page, perPage: perPage);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getStageLeaderboard(int stageId, {int? page, int? perPage}) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getStageLeaderboard(stageId, page: page, perPage: perPage);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getTournamentLeaderboard(int tournamentId, {int? page, int? perPage}) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getTournamentLeaderboard(tournamentId, page: page, perPage: perPage);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LeaderboardItemEntity>> getMatchLeaderboard(int matchId, {int? page, int? perPage}) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getMatchLeaderboard(matchId, page: page, perPage: perPage);
    return models.map((m) => m.toEntity()).toList();
  }
}
