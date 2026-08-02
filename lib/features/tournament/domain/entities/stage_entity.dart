import 'package:equatable/equatable.dart';

class StageEntity extends Equatable {
  const StageEntity({
    required this.id,
    required this.tournamentId,
    required this.name,
    required this.stageType,
    this.order,
    this.status,
    this.teamsCount,
    this.roundsCount,
    this.matchesCount,
    this.createdAt,
  });

  final int id;
  final int tournamentId;
  final String name;
  final String stageType;
  final int? order;
  final String? status;
  final int? teamsCount;
  final int? roundsCount;
  final int? matchesCount;
  final String? createdAt;

  @override
  List<Object?> get props => [
        id,
        tournamentId,
        name,
        stageType,
        order,
        status,
        teamsCount,
        roundsCount,
        matchesCount,
        createdAt,
      ];
}
