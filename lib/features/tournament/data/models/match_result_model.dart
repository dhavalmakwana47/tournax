import '../../domain/entities/match_result_entity.dart';

int _toInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? defaultValue;
  return defaultValue;
}

int? _toNullableInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

class PlayerResultModel {
  const PlayerResultModel({
    required this.playerId,
    this.playerName,
    required this.kills,
    required this.assists,
    required this.damage,
    required this.headshots,
    required this.revives,
    required this.healing,
    required this.survivalTime,
    required this.finishes,
  });

  final int playerId;
  final String? playerName;
  final int kills;
  final int assists;
  final int damage;
  final int headshots;
  final int revives;
  final int healing;
  final int survivalTime;
  final int finishes;

  factory PlayerResultModel.fromJson(Map<String, dynamic> json) => PlayerResultModel(
        playerId: _toInt(json['player_id']),
        playerName: json['player_name'] as String?,
        kills: _toInt(json['kills']),
        assists: _toInt(json['assists']),
        damage: _toInt(json['damage']),
        headshots: _toInt(json['headshots']),
        revives: _toInt(json['revives']),
        healing: _toInt(json['healing']),
        survivalTime: _toInt(json['survival_time']),
        finishes: _toInt(json['finishes']),
      );

  Map<String, dynamic> toJson() => {
        'player_id': playerId,
        if (playerName != null) 'player_name': playerName,
        'kills': kills,
        'assists': assists,
        'damage': damage,
        'headshots': headshots,
        'revives': revives,
        'healing': healing,
        'survival_time': survivalTime,
        'finishes': finishes,
      };

  PlayerResultEntity toEntity() => PlayerResultEntity(
        playerId: playerId,
        playerName: playerName,
        kills: kills,
        assists: assists,
        damage: damage,
        headshots: headshots,
        revives: revives,
        healing: healing,
        survivalTime: survivalTime,
        finishes: finishes,
      );
}

class TeamResultModel {
  const TeamResultModel({
    this.id,
    required this.matchId,
    required this.teamId,
    this.teamName,
    this.teamShortName,
    required this.rank,
    this.placementPoints,
    this.killPoints,
    required this.bonusPoints,
    required this.penaltyPoints,
    this.totalPoints,
    required this.kills,
    required this.survivalTime,
    this.players = const [],
  });

  final int? id;
  final int matchId;
  final int teamId;
  final String? teamName;
  final String? teamShortName;
  final int rank;
  final int? placementPoints;
  final int? killPoints;
  final int bonusPoints;
  final int penaltyPoints;
  final int? totalPoints;
  final int kills;
  final int survivalTime;
  final List<PlayerResultModel> players;

  factory TeamResultModel.fromJson(Map<String, dynamic> json) => TeamResultModel(
        id: _toNullableInt(json['id']),
        matchId: _toInt(json['match_id']),
        teamId: _toInt(json['team_id']),
        teamName: json['team_name'] as String?,
        teamShortName: json['team_short_name'] as String?,
        rank: _toInt(json['rank'], 1),
        placementPoints: _toNullableInt(json['placement_points']),
        killPoints: _toNullableInt(json['kill_points']),
        bonusPoints: _toInt(json['bonus_points']),
        penaltyPoints: _toInt(json['penalty_points']),
        totalPoints: _toNullableInt(json['total_points']),
        kills: _toInt(json['kills']),
        survivalTime: _toInt(json['survival_time']),
        players: json['players'] is List
            ? (json['players'] as List)
                .map((e) => PlayerResultModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'match_id': matchId,
        'team_id': teamId,
        if (teamName != null) 'team_name': teamName,
        if (teamShortName != null) 'team_short_name': teamShortName,
        'rank': rank,
        if (placementPoints != null) 'placement_points': placementPoints,
        if (killPoints != null) 'kill_points': killPoints,
        'bonus_points': bonusPoints,
        'penalty_points': penaltyPoints,
        if (totalPoints != null) 'total_points': totalPoints,
        'kills': kills,
        'survival_time': survivalTime,
        'players': players.map((e) => e.toJson()).toList(),
      };

  TeamResultEntity toEntity() => TeamResultEntity(
        id: id,
        matchId: matchId,
        teamId: teamId,
        teamName: teamName,
        teamShortName: teamShortName,
        rank: rank,
        placementPoints: placementPoints,
        killPoints: killPoints,
        bonusPoints: bonusPoints,
        penaltyPoints: penaltyPoints,
        totalPoints: totalPoints,
        kills: kills,
        survivalTime: survivalTime,
        players: players.map((e) => e.toEntity()).toList(),
      );
}
