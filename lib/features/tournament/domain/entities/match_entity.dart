import 'package:equatable/equatable.dart';

class MatchTeamMemberEntity extends Equatable {
  const MatchTeamMemberEntity({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.country,
    this.slot,
    this.lane,
    required this.status,
  });

  final int id;
  final String name;
  final String? shortName;
  final String? logo;
  final String? country;
  final int? slot;
  final String? lane;
  final String status;

  @override
  List<Object?> get props => [id, name, shortName, logo, country, slot, lane, status];
}

class MatchEntity extends Equatable {
  const MatchEntity({
    required this.id,
    required this.groupId,
    required this.matchNumber,
    this.name,
    this.map,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.status,
    this.teams = const [],
  });

  final int id;
  final int groupId;
  final int matchNumber;
  final String? name;
  final String? map;
  final String? scheduledAt;
  final String? startedAt;
  final String? endedAt;
  final String status;
  final List<MatchTeamMemberEntity> teams;

  @override
  List<Object?> get props => [
        id,
        groupId,
        matchNumber,
        name,
        map,
        scheduledAt,
        startedAt,
        endedAt,
        status,
        teams,
      ];
}
