import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_search_result.dart';
import 'player_search_model.dart';

class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.name,
    required this.teamId,
    this.userId,
    this.user,
    this.gameUid,
    this.role,
    this.createdAt,
  });

  final int id;
  final String name;
  final int teamId;
  final int? userId;
  final PlayerSearchResult? user;
  final String? gameUid;
  final String? role;
  final String? createdAt;

  factory PlayerModel.fromJson(Map<String, dynamic> json, {int? teamId}) {
    PlayerSearchResult? userObj;
    if (json['user'] is Map<String, dynamic>) {
      userObj = PlayerSearchModel.fromJson(json['user'] as Map<String, dynamic>)
          .toEntity();
    }
    return PlayerModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      teamId: (json['team_id'] as num?)?.toInt() ?? teamId ?? 0,
      userId: (json['user_id'] as num?)?.toInt(),
      user: userObj,
      gameUid: json['game_uid'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  PlayerEntity toEntity() => PlayerEntity(
        id: id,
        name: name,
        teamId: teamId,
        userId: userId,
        user: user,
        gameUid: gameUid,
        role: role,
        createdAt: createdAt,
      );
}
