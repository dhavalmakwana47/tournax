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
    this.startDate,
    this.endDate,
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

  @JsonKey(name: 'start_date')
  final String? startDate;

  @JsonKey(name: 'end_date')
  final String? endDate;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentModelToJson(this);
}
