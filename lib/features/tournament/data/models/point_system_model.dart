import '../../domain/entities/point_system_entity.dart';

class PointSystemRuleModel {
  const PointSystemRuleModel({
    required this.id,
    required this.placement,
    required this.placementPoints,
  });

  final int id;
  final int placement;
  final double placementPoints;

  factory PointSystemRuleModel.fromJson(Map<String, dynamic> json) =>
      PointSystemRuleModel(
        id: (json['id'] as num).toInt(),
        placement: (json['placement'] as num).toInt(),
        placementPoints: (json['placement_points'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'placement': placement,
        'placement_points': placementPoints,
      };

  PointSystemRuleEntity toEntity() => PointSystemRuleEntity(
        id: id,
        placement: placement,
        placementPoints: placementPoints,
      );
}

class PointSystemModel {
  const PointSystemModel({
    required this.id,
    this.groupId,
    required this.name,
    required this.code,
    required this.killPoint,
    this.description,
    required this.isDefault,
    required this.status,
    this.createdAt,
    this.rules = const [],
  });

  final int id;
  final int? groupId;
  final String name;
  final String code;
  final double killPoint;
  final String? description;
  final bool isDefault;
  final bool status;
  final String? createdAt;
  final List<PointSystemRuleModel> rules;

  factory PointSystemModel.fromJson(Map<String, dynamic> json) =>
      PointSystemModel(
        id: (json['id'] as num).toInt(),
        groupId: (json['group_id'] as num?)?.toInt(),
        name: json['name'] as String,
        code: json['code'] as String,
        killPoint: (json['kill_point'] as num).toDouble(),
        description: json['description'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
        status: json['status'] as bool? ?? true,
        createdAt: json['created_at'] as String?,
        rules: json['rules'] is List
            ? (json['rules'] as List)
                .map((e) => PointSystemRuleModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_id': groupId,
        'name': name,
        'code': code,
        'kill_point': killPoint,
        'description': description,
        'is_default': isDefault,
        'status': status,
        'created_at': createdAt,
        'rules': rules.map((e) => e.toJson()).toList(),
      };

  PointSystemEntity toEntity() => PointSystemEntity(
        id: id,
        groupId: groupId,
        name: name,
        code: code,
        killPoint: killPoint,
        description: description,
        isDefault: isDefault,
        status: status,
        createdAt: createdAt,
        rules: rules.map((e) => e.toEntity()).toList(),
      );
}
