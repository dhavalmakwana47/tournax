import '../../domain/entities/team_entity.dart';

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    required this.tournamentId,
    this.playerCount = 0,
    this.createdAt,
  });

  final int id;
  final String name;
  final int tournamentId;
  final int playerCount;
  final String? createdAt;

  factory TeamModel.fromJson(Map<String, dynamic> json, {int? tournamentId}) => TeamModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        tournamentId: (json['tournament_id'] as num?)?.toInt() ?? tournamentId ?? 0,
        playerCount: (json['player_count'] as num?)?.toInt() ??
            (json['players'] is List ? (json['players'] as List).length : 0),
        createdAt: json['created_at'] as String?,
      );

  TeamEntity toEntity() => TeamEntity(
        id: id,
        name: name,
        tournamentId: tournamentId,
        playerCount: playerCount,
        createdAt: createdAt,
      );
}
