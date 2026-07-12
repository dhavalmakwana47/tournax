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
    this.description,
    this.startDate,
    this.endDate,
    this.registrationStart,
    this.registrationEnd,
    this.checkInEnabled = false,
    this.allowSubstitute = false,
    this.autoQualify = false,
    this.leaderboardType,
    this.rules,
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
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? registrationStart;
  final String? registrationEnd;
  final bool checkInEnabled;
  final bool allowSubstitute;
  final bool autoQualify;
  final String? leaderboardType;
  final String? rules;
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
        description,
        startDate,
        endDate,
        registrationStart,
        registrationEnd,
        checkInEnabled,
        allowSubstitute,
        autoQualify,
        leaderboardType,
        rules,
        createdAt,
      ];
}
