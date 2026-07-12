import 'package:json_annotation/json_annotation.dart';

part 'tournament_model.g.dart';

@JsonSerializable()
class TournamentModel {
  const TournamentModel({
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

  @JsonKey(name: 'tournament_type')
  final String tournamentType;

  final String status;

  @JsonKey(name: 'max_teams')
  final int maxTeams;

  @JsonKey(name: 'max_players_per_team')
  final int maxPlayersPerTeam;

  final String? description;

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'end_date')
  final String? endDate;

  @JsonKey(name: 'registration_start')
  final String? registrationStart;

  @JsonKey(name: 'registration_end')
  final String? registrationEnd;

  @JsonKey(name: 'check_in_enabled')
  final bool checkInEnabled;

  @JsonKey(name: 'allow_substitute')
  final bool allowSubstitute;

  @JsonKey(name: 'auto_qualify')
  final bool autoQualify;

  @JsonKey(name: 'leaderboard_type')
  final String? leaderboardType;

  final String? rules;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentModelToJson(this);
}
