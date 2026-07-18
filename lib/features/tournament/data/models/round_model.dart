import '../../domain/entities/round_entity.dart';

class RoundModel {
  const RoundModel({
    required this.id,
    required this.stageId,
    required this.name,
    required this.roundNumber,
    this.numberOfGroups = 1,
    required this.status,
    this.createdAt,
  });

  final int id;
  final int stageId;
  final String name;
  final int roundNumber;
  final int numberOfGroups;
  final String status;
  final String? createdAt;

  factory RoundModel.fromJson(Map<String, dynamic> json, {int? stageId}) => RoundModel(
        id: (json['id'] as num).toInt(),
        stageId: (json['stage_id'] as num?)?.toInt() ?? stageId ?? 0,
        name: json['name'] as String,
        roundNumber: (json['round_number'] as num?)?.toInt() ?? 0,
        numberOfGroups: (json['number_of_groups'] as num?)?.toInt() ?? 1,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stage_id': stageId,
        'name': name,
        'round_number': roundNumber,
        'number_of_groups': numberOfGroups,
        'status': status,
        'created_at': createdAt,
      };

  RoundEntity toEntity() => RoundEntity(
        id: id,
        stageId: stageId,
        name: name,
        roundNumber: roundNumber,
        numberOfGroups: numberOfGroups,
        status: status,
        createdAt: createdAt,
      );
}
