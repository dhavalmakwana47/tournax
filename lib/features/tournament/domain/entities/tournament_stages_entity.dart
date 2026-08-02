import 'package:equatable/equatable.dart';

class TournamentStagesEntity extends Equatable {
  const TournamentStagesEntity({
    required this.total,
    required this.completed,
    required this.completedPercentage,
  });

  final int total;
  final int completed;
  final double completedPercentage;

  @override
  List<Object?> get props => [total, completed, completedPercentage];
}
