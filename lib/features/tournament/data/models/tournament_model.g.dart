// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentModel _$TournamentModelFromJson(Map<String, dynamic> json) {
  final settings = json['settings'] as Map<String, dynamic>? ?? {};
  return TournamentModel(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    slug: json['slug'] as String,
    mode: json['mode'] as String,
    tournamentType: json['tournament_type'] as String,
    status: json['status'] as String,
    maxTeams: (json['max_teams'] as num).toInt(),
    maxPlayersPerTeam: (json['max_players_per_team'] as num).toInt(),
    description: json['description'] as String?,
    startDate: json['start_date'] as String?,
    endDate: json['end_date'] as String?,
    registrationStart: settings['registration_start'] as String?,
    registrationEnd: settings['registration_end'] as String?,
    checkInEnabled: settings['check_in_enabled'] as bool? ?? false,
    allowSubstitute: settings['allow_substitute'] as bool? ?? false,
    autoQualify: settings['auto_qualify'] as bool? ?? false,
    leaderboardType: settings['leaderboard_type'] as String?,
    rules: settings['rules'] as String?,
    createdAt: json['created_at'] as String?,
  );
}

Map<String, dynamic> _$TournamentModelToJson(TournamentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'mode': instance.mode,
      'tournament_type': instance.tournamentType,
      'status': instance.status,
      'max_teams': instance.maxTeams,
      'max_players_per_team': instance.maxPlayersPerTeam,
      'description': instance.description,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'registration_start': instance.registrationStart,
      'registration_end': instance.registrationEnd,
      'check_in_enabled': instance.checkInEnabled,
      'allow_substitute': instance.allowSubstitute,
      'auto_qualify': instance.autoQualify,
      'leaderboard_type': instance.leaderboardType,
      'rules': instance.rules,
      'created_at': instance.createdAt,
    };
