import '../entities/match_entity.dart';
import '../entities/match_result_entity.dart';

abstract interface class MatchRepository {
  Future<List<MatchEntity>> getMatches(int groupId);
  Future<MatchEntity> createMatch({
    required int groupId,
    required int matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? status,
  });
  Future<MatchEntity> showMatch(int matchId);
  Future<MatchEntity> updateMatch({
    required int matchId,
    int? matchNumber,
    String? name,
    String? map,
    String? scheduledAt,
    String? startedAt,
    String? endedAt,
    String? status,
  });
  Future<void> deleteMatch(int matchId);
  Future<MatchEntity> addTeamToMatch({
    required int matchId,
    required int teamId,
    int? slot,
    String? lane,
  });
  Future<MatchEntity> removeTeamFromMatch({
    required int matchId,
    required int teamId,
  });
  Future<void> submitMatchResults({
    required int matchId,
    required List<TeamResultEntity> results,
  });
  Future<List<TeamResultEntity>> getMatchResults(int matchId);
  Future<void> deleteMatchResults(int matchId);
}
