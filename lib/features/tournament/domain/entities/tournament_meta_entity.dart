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
  });

  final List<MetaOption> modes;
  final List<MetaOption> tournamentTypes;

  @override
  List<Object> get props => [modes, tournamentTypes];
}
