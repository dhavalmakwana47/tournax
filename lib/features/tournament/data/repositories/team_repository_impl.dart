import '../../../../core/api/api_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasource/team_remote_datasource.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final TeamRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<TeamEntity>> getTeams(int tournamentId) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getTeams(tournamentId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TeamEntity> createTeam({
    required int tournamentId,
    required String name,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model =
        await remoteDatasource.createTeam(tournamentId: tournamentId, name: name);
    return model.toEntity();
  }

  @override
  Future<TeamEntity> getTeam({
    required int tournamentId,
    required int teamId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.getTeam(
        tournamentId: tournamentId, teamId: teamId);
    return model.toEntity();
  }

  @override
  Future<TeamEntity> updateTeam({
    required int tournamentId,
    required int teamId,
    required String name,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.updateTeam(
        tournamentId: tournamentId, teamId: teamId, name: name);
    return model.toEntity();
  }

  @override
  Future<List<PlayerEntity>> getPlayers({
    required int tournamentId,
    required int teamId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final models = await remoteDatasource.getPlayers(
        tournamentId: tournamentId, teamId: teamId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PlayerEntity> addPlayer({
    required int tournamentId,
    required int teamId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.addPlayer(
      tournamentId: tournamentId,
      teamId: teamId,
      name: name,
      gameUid: gameUid,
      role: role,
      userId: userId,
    );
    return model.toEntity();
  }

  @override
  Future<PlayerEntity> getPlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.getPlayer(
        tournamentId: tournamentId, teamId: teamId, playerId: playerId);
    return model.toEntity();
  }

  @override
  Future<PlayerEntity> updatePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    final model = await remoteDatasource.updatePlayer(
      tournamentId: tournamentId,
      teamId: teamId,
      playerId: playerId,
      name: name,
      gameUid: gameUid,
      role: role,
      userId: userId,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteTeam({
    required int tournamentId,
    required int teamId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deleteTeam(
        tournamentId: tournamentId, teamId: teamId);
  }

  @override
  Future<void> deletePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  }) async {
    if (!await networkInfo.isConnected) throw ApiException.noInternet();
    await remoteDatasource.deletePlayer(
        tournamentId: tournamentId, teamId: teamId, playerId: playerId);
  }
}
