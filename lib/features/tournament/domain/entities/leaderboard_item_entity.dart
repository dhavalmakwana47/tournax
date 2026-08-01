import 'package:equatable/equatable.dart';

class LeaderboardItemEntity extends Equatable {
  const LeaderboardItemEntity({
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

  @override
  List<Object?> get props => [
        id,
        teamId,
        teamName,
        matches,
        wins,
        kills,
        points,
        rank,
        killPoints,
        placementPoints,
      ];
}
