import '../../domain/entities/leaderboard_item_entity.dart';

class LeaderboardItemModel {
  const LeaderboardItemModel({
    required this.id,
    required this.teamId,
    this.teamName,
    required this.matches,
    required this.wins,
    required this.kills,
    required this.points,
    this.rank,
    this.killPoints = 0,
    this.placementPoints = 0,
  });

  final int id;
  final int teamId;
  final String? teamName;
  final int matches;
  final int wins;
  final int kills;
  final int points;
  final int? rank;
  final int killPoints;
  final int placementPoints;

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    String? name = json['team_name'] as String?;
    if ((name == null || name.isEmpty) && json['team'] is Map) {
      name = (json['team'] as Map)['name'] as String?;
    }

    final int id = (json['id'] as num?)?.toInt() ?? 0;
    final int teamId = (json['team_id'] as num?)?.toInt() ?? 0;
    final int matches = (json['matches'] as num?)?.toInt() ?? 1;
    final int rankVal = (json['rank'] as num?)?.toInt() ?? 1;
    final int wins = (json['wins'] as num?)?.toInt() ?? (rankVal == 1 ? 1 : 0);
    final int killsVal = (json['kill_points'] as num?)?.toInt() ?? (json['kills'] as num?)?.toInt() ?? 0;
    final int placePtsVal = (json['placement_points'] as num?)?.toInt() ?? 0;
    final int pointsVal = (json['total_points'] as num?)?.toInt() ??
        (json['points'] as num?)?.toInt() ??
        (killsVal + placePtsVal);

    return LeaderboardItemModel(
      id: id,
      teamId: teamId,
      teamName: name,
      matches: matches,
      wins: wins,
      kills: killsVal,
      points: pointsVal,
      rank: rankVal,
      killPoints: killsVal,
      placementPoints: placePtsVal,
    );
  }

  LeaderboardItemEntity toEntity() {
    return LeaderboardItemEntity(
      id: id,
      teamId: teamId,
      teamName: teamName,
      matches: matches,
      wins: wins,
      kills: kills,
      points: points,
      rank: rank,
      killPoints: killPoints,
      placementPoints: placementPoints,
    );
  }
}
