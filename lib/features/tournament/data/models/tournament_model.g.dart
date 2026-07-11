// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentModel _$TournamentModelFromJson(Map<String, dynamic> json) =>
    TournamentModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      mode: json['mode'] as String,
      tournamentType: json['tournament_type'] as String,
      status: json['status'] as String,
      maxTeams: (json['max_teams'] as num).toInt(),
      maxPlayersPerTeam: (json['max_players_per_team'] as num).toInt(),
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      createdAt: json['created_at'] as String?,
    );

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
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'created_at': instance.createdAt,
    };
