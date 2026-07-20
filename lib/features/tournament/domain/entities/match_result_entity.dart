import 'package:equatable/equatable.dart';

class PlayerResultEntity extends Equatable {
  const PlayerResultEntity({
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

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        kills,
        assists,
        damage,
        headshots,
        revives,
        healing,
        survivalTime,
        finishes,
      ];
}

class TeamResultEntity extends Equatable {
  const TeamResultEntity({
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
  final List<PlayerResultEntity> players;

  @override
  List<Object?> get props => [
        id,
        matchId,
        teamId,
        teamName,
        teamShortName,
        rank,
        placementPoints,
        killPoints,
        bonusPoints,
        penaltyPoints,
        totalPoints,
        kills,
        survivalTime,
        players,
      ];
}
