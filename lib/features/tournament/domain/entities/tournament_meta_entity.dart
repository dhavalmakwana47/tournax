import 'package:equatable/equatable.dart';

class MetaOption extends Equatable {
  const MetaOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object> get props => [value, label];
}

class TournamentMetaEntity extends Equatable {
  const TournamentMetaEntity({
    required this.modes,
    required this.tournamentTypes,
    required this.playerRoles,
    this.stageTypes = const [],
  });

  final List<MetaOption> modes;
  final List<MetaOption> tournamentTypes;
  final List<MetaOption> playerRoles;
  final List<MetaOption> stageTypes;

  @override
  List<Object> get props => [modes, tournamentTypes, playerRoles, stageTypes];
}
