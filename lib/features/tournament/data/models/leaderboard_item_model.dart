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
  });

  final int id;
  final int teamId;
  final String? teamName;
  final int matches;
  final int wins;
  final int kills;
  final int points;
  final int? rank;

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardItemModel(
      id: json['id'] as int,
      teamId: json['team_id'] as int,
      teamName: json['team_name'] as String?,
      matches: json['matches'] as int,
      wins: json['wins'] as int,
      kills: json['kills'] as int,
      points: json['points'] as int,
      rank: json['rank'] as int?,
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
    );
  }
}
