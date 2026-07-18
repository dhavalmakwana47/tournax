import 'package:equatable/equatable.dart';

class GroupTeamMember extends Equatable {
  const GroupTeamMember({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.country,
    this.seed,
    this.joinedAt,
  });

  final int id;
  final String name;
  final String? shortName;
  final String? logo;
  final String? country;
  final int? seed;
  final String? joinedAt;

  @override
  List<Object?> get props => [id, name, shortName, logo, country, seed, joinedAt];
}

class GroupEntity extends Equatable {
  const GroupEntity({
    required this.id,
    required this.roundId,
    required this.name,
    required this.displayOrder,
    required this.status,
    this.createdAt,
    this.teams,
  });

  final int id;
  final int roundId;
  final String name;
  final int displayOrder;
  final String status;
  final String? createdAt;
  final List<GroupTeamMember>? teams;

  @override
  List<Object?> get props =>
      [id, roundId, name, displayOrder, status, createdAt, teams];
}
