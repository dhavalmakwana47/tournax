import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  const TeamEntity({
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

  @override
  List<Object?> get props => [id, name, tournamentId, playerCount, createdAt];
}
