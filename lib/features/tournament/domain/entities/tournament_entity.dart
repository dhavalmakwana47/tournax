import 'package:equatable/equatable.dart';

class TournamentEntity extends Equatable {
  const TournamentEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.mode,
    required this.tournamentType,
    required this.status,
    required this.maxTeams,
    required this.maxPlayersPerTeam,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  final int id;
  final String name;
  final String slug;
  final String mode;
  final String tournamentType;
  final String status;
  final int maxTeams;
  final int maxPlayersPerTeam;
  final String? startDate;
  final String? endDate;
  final String? createdAt;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        mode,
        tournamentType,
        status,
        maxTeams,
        maxPlayersPerTeam,
        startDate,
        endDate,
        createdAt,
      ];
}
