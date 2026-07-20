import '../../../../core/network/network_info.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/entities/match_result_entity.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasource/match_remote_datasource.dart';
import '../models/match_result_model.dart';

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final MatchRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<List<MatchEntity>> getMatches(int groupId) async {
    final list = await remoteDatasource.getMatches(groupId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<MatchEntity> createMatch({
    required int groupId,
    required int matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? status,
  }) async {
    final model = await remoteDatasource.createMatch(
      groupId: groupId,
      matchNumber: matchNumber,
      name: name,
      map: map,
      scheduledAt: scheduledAt,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<MatchEntity> showMatch(int matchId) async {
    final model = await remoteDatasource.showMatch(matchId);
    return model.toEntity();
  }

  @override
  Future<MatchEntity> updateMatch({
    required int matchId,
    int? matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? startedAt,
    String? endedAt,
    String? status,
  }) async {
    final model = await remoteDatasource.updateMatch(
      matchId: matchId,
      matchNumber: matchNumber,
      name: name,
      map: map,
      scheduledAt: scheduledAt,
      startedAt: startedAt,
      endedAt: endedAt,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteMatch(int matchId) async {
    await remoteDatasource.deleteMatch(matchId);
  }

  @override
  Future<MatchEntity> addTeamToMatch({
    required int matchId,
    required int teamId,
    int? slot,
    String? lane,
  }) async {
    final model = await remoteDatasource.addTeamToMatch(
      matchId: matchId,
      teamId: teamId,
      slot: slot,
      lane: lane,
    );
    return model.toEntity();
  }

  @override
  Future<MatchEntity> removeTeamFromMatch({
    required int matchId,
    required int teamId,
  }) async {
    final model = await remoteDatasource.removeTeamFromMatch(
      matchId: matchId,
      teamId: teamId,
    );
    return model.toEntity();
  }

  @override
  Future<void> submitMatchResults({
    required int matchId,
    required List<TeamResultEntity> results,
  }) async {
    final models = results.map((e) => TeamResultModel(
      matchId: e.matchId,
      teamId: e.teamId,
      rank: e.rank,
      bonusPoints: e.bonusPoints,
      penaltyPoints: e.penaltyPoints,
      kills: e.kills,
      survivalTime: e.survivalTime,
      players: e.players.map((p) => PlayerResultModel(
        playerId: p.playerId,
        kills: p.kills,
        assists: p.assists,
        damage: p.damage,
        headshots: p.headshots,
        revives: p.revives,
        healing: p.healing,
        survivalTime: p.survivalTime,
        finishes: p.finishes,
      )).toList(),
    ));
    await remoteDatasource.submitMatchResults(
      matchId: matchId,
      results: models.map((m) => m.toJson()).toList(),
    );
  }

  @override
  Future<List<TeamResultEntity>> getMatchResults(int matchId) async {
    final list = await remoteDatasource.getMatchResults(matchId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteMatchResults(int matchId) async {
    await remoteDatasource.deleteMatchResults(matchId);
  }
}
