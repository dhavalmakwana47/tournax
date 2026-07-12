import '../../domain/entities/stage_entity.dart';

class StageModel {
  const StageModel({
    required this.id,
    required this.tournamentId,
    required this.name,
    required this.stageType,
    this.order,
    this.status,
    this.createdAt,
  });

  final int id;
  final int tournamentId;
  final String name;
  final String stageType;
  final int? order;
  final String? status;
  final String? createdAt;

  factory StageModel.fromJson(Map<String, dynamic> json, {int? tournamentId}) => StageModel(
        id: (json['id'] as num).toInt(),
        tournamentId: (json['tournament_id'] as num?)?.toInt() ?? tournamentId ?? 0,
        name: json['name'] as String,
        stageType: json['stage_type'] as String,
        order: (json['order'] as num?)?.toInt(),
        status: json['status'] as String?,
        createdAt: json['created_at'] as String?,
      );

  StageEntity toEntity() => StageEntity(
        id: id,
        tournamentId: tournamentId,
        name: name,
        stageType: stageType,
        order: order,
        status: status,
        createdAt: createdAt,
      );
}
