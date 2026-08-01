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
    this.leaderboardTypes = const [],
    List<MetaOption>? statuses,
  }) : _statuses = statuses;

  final List<MetaOption> modes;
  final List<MetaOption> tournamentTypes;
  final List<MetaOption> playerRoles;
  final List<MetaOption> stageTypes;
  final List<MetaOption> leaderboardTypes;
  final List<MetaOption>? _statuses;

  static const defaultStatuses = [
    MetaOption(value: 'draft', label: 'Draft'),
    MetaOption(value: 'published', label: 'Published'),
    MetaOption(value: 'live', label: 'Live'),
    MetaOption(value: 'completed', label: 'Completed'),
  ];

  List<MetaOption> get statuses =>
      (_statuses != null && _statuses!.isNotEmpty) ? _statuses! : defaultStatuses;

  @override
  List<Object> get props =>
      [modes, tournamentTypes, playerRoles, stageTypes, leaderboardTypes, statuses];
}
