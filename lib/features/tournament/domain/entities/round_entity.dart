import 'package:equatable/equatable.dart';

class RoundEntity extends Equatable {
  const RoundEntity({
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

  @override
  List<Object?> get props => [id, stageId, name, roundNumber, numberOfGroups, status, createdAt];
}
