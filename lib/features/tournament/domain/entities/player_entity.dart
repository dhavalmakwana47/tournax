import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  const PlayerEntity({
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

  @override
  List<Object?> get props => [id, name, teamId, gameUid, role, createdAt];
}
