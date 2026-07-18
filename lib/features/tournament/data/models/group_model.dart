import '../../domain/entities/group_entity.dart';

class GroupTeamMemberModel {
  const GroupTeamMemberModel({
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

  factory GroupTeamMemberModel.fromJson(Map<String, dynamic> json) =>
      GroupTeamMemberModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        shortName: json['short_name'] as String?,
        logo: json['logo'] as String?,
        country: json['country'] as String?,
        seed: (json['seed'] as num?)?.toInt(),
        joinedAt: json['joined_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_name': shortName,
        'logo': logo,
        'country': country,
        'seed': seed,
        'joined_at': joinedAt,
      };

  GroupTeamMember toEntity() => GroupTeamMember(
        id: id,
        name: name,
        shortName: shortName,
        logo: logo,
        country: country,
        seed: seed,
        joinedAt: joinedAt,
      );
}

class GroupModel {
  const GroupModel({
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
  final List<GroupTeamMemberModel>? teams;

  factory GroupModel.fromJson(Map<String, dynamic> json, {int? roundId}) =>
      GroupModel(
        id: (json['id'] as num).toInt(),
        roundId: (json['round_id'] as num?)?.toInt() ?? roundId ?? 0,
        name: json['name'] as String,
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String?,
        teams: json['teams'] is List
            ? (json['teams'] as List)
                .map((e) => GroupTeamMemberModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'round_id': roundId,
        'name': name,
        'display_order': displayOrder,
        'status': status,
        'created_at': createdAt,
        'teams': teams?.map((e) => e.toJson()).toList(),
      };

  GroupEntity toEntity() => GroupEntity(
        id: id,
        roundId: roundId,
        name: name,
        displayOrder: displayOrder,
        status: status,
        createdAt: createdAt,
        teams: teams?.map((e) => e.toEntity()).toList(),
      );
}
