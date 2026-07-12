import '../../domain/entities/player_entity.dart';

class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.name,
    required this.teamId,
    this.gameUid,
    this.role,
    this.createdAt,
  });

  final int id;
  final String name;
  final int teamId;
  final String? gameUid;
  final String? role;
  final String? createdAt;

  factory PlayerModel.fromJson(Map<String, dynamic> json, {int? teamId}) =>
      PlayerModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        teamId: (json['team_id'] as num?)?.toInt() ?? teamId ?? 0,
        gameUid: json['game_uid'] as String?,
        role: json['role'] as String?,
        createdAt: json['created_at'] as String?,
      );

  PlayerEntity toEntity() => PlayerEntity(
        id: id,
        name: name,
        teamId: teamId,
        gameUid: gameUid,
        role: role,
        createdAt: createdAt,
      );
}
