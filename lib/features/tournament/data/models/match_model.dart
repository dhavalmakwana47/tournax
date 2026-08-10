import '../../domain/entities/match_entity.dart';

int _toInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? defaultValue;
  return defaultValue;
}

int? _toNullableInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

class MatchTeamMemberModel {
  const MatchTeamMemberModel({
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

  factory MatchTeamMemberModel.fromJson(Map<String, dynamic> json) =>
      MatchTeamMemberModel(
        id: _toInt(json['id']),
        name: json['name']?.toString() ?? '',
        shortName: json['short_name'] as String?,
        logo: json['logo'] as String?,
        country: json['country'] as String?,
        slot: _toNullableInt(json['slot']) ??
            (json['pivot'] is Map ? _toNullableInt(json['pivot']['slot']) : null) ??
            _toNullableInt(json['slot_number']) ??
            (json['pivot'] is Map ? _toNullableInt(json['pivot']['slot_number']) : null),
        lane: json['lane'] as String?,
        status: json['status'] as String? ?? 'confirmed',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
        'logo': logo,
        'country': country,
        'slot': slot,
        'lane': lane,
        'status': status,
      };

  MatchTeamMemberEntity toEntity() => MatchTeamMemberEntity(
        id: id,
        name: name,
        shortName: shortName,
        logo: logo,
        country: country,
        slot: slot,
        lane: lane,
        status: status,
      );
}

class MatchModel {
  const MatchModel({
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
  final List<MatchTeamMemberModel> teams;

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: _toInt(json['id']),
        groupId: _toInt(json['group_id']),
        matchNumber: _toInt(json['match_number']),
        name: json['name'] as String?,
        map: json['map'] as String?,
        scheduledAt: json['scheduled_at'] as String?,
        startedAt: json['started_at'] as String?,
        endedAt: json['ended_at'] as String?,
        status: json['status'] as String? ?? 'scheduled',
        teams: json['teams'] is List
            ? (json['teams'] as List)
                .map((e) => MatchTeamMemberModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_id': groupId,
        'match_number': matchNumber,
        'name': name,
        'map': map,
        'scheduled_at': scheduledAt,
        'started_at': startedAt,
        'ended_at': endedAt,
        'status': status,
        'teams': teams.map((e) => e.toJson()).toList(),
      };

  MatchEntity toEntity() => MatchEntity(
        id: id,
        groupId: groupId,
        matchNumber: matchNumber,
        name: name,
        map: map,
        scheduledAt: scheduledAt,
        startedAt: startedAt,
        endedAt: endedAt,
        status: status,
        teams: teams.map((e) => e.toEntity()).toList(),
      );
}
