import 'package:equatable/equatable.dart';
import 'player_search_result.dart';

class PlayerEntity extends Equatable {
  const PlayerEntity({
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

  @override
  List<Object?> get props =>
      [id, name, teamId, userId, user, gameUid, role, createdAt];
}
