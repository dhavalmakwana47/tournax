import 'package:equatable/equatable.dart';

class PointSystemRuleEntity extends Equatable {
  const PointSystemRuleEntity({
    required this.id,
    required this.placement,
    required this.placementPoints,
  });

  final int id;
  final int placement;
  final double placementPoints;

  @override
  List<Object?> get props => [id, placement, placementPoints];
}

class PointSystemEntity extends Equatable {
  const PointSystemEntity({
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
  final List<PointSystemRuleEntity> rules;

  @override
  List<Object?> get props => [
        id,
        groupId,
        name,
        code,
        killPoint,
        description,
        isDefault,
        status,
        createdAt,
        rules,
      ];
}
