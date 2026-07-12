import '../entities/player_entity.dart';
import '../entities/team_entity.dart';

abstract interface class TeamRepository {
  Future<List<TeamEntity>> getTeams(int tournamentId);
  Future<TeamEntity> createTeam({
    required int tournamentId,
    required String name,
  });
  Future<TeamEntity> getTeam({
    required int tournamentId,
    required int teamId,
  });
  Future<TeamEntity> updateTeam({
    required int tournamentId,
    required int teamId,
    required String name,
  });
  Future<List<PlayerEntity>> getPlayers({
    required int tournamentId,
    required int teamId,
  });
  Future<PlayerEntity> addPlayer({
    required int tournamentId,
    required int teamId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  });
  Future<PlayerEntity> getPlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  });
  Future<PlayerEntity> updatePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
    required String name,
    String? gameUid,
    String? role,
    int? userId,
  });
  Future<void> deleteTeam({
    required int tournamentId,
    required int teamId,
  });
  Future<void> deletePlayer({
    required int tournamentId,
    required int teamId,
    required int playerId,
  });
}
