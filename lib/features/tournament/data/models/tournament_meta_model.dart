import '../../domain/entities/tournament_meta_entity.dart';

class TournamentMetaModel {
  const TournamentMetaModel({
    required this.modes,
    required this.tournamentTypes,
    required this.playerRoles,
    this.stageTypes = const [],
    this.leaderboardTypes = const [],
    this.statuses = const [],
    this.stageStatuses = const [],
  });

  final List<MetaOption> modes;
  final List<MetaOption> tournamentTypes;
  final List<MetaOption> playerRoles;
  final List<MetaOption> stageTypes;
  final List<MetaOption> leaderboardTypes;
  final List<MetaOption> statuses;
  final List<MetaOption> stageStatuses;

  factory TournamentMetaModel.fromJson(Map<String, dynamic> json) {
    List<MetaOption> toOptionList(dynamic raw) {
      if (raw is! List) return const [];
      return raw.map((e) {
        final map = e as Map<String, dynamic>;
        return MetaOption(
          value: map['value'].toString(),
          label: map['label'].toString(),
        );
      }).toList();
    }

    final parsedStatuses = toOptionList(
        json['status'] ?? json['statuses'] ?? json['tournament_statuses'] ?? json['status_options']);
    final defaultStatuses = const [
      MetaOption(value: 'draft', label: 'Draft'),
      MetaOption(value: 'published', label: 'Published'),
      MetaOption(value: 'live', label: 'Live'),
      MetaOption(value: 'completed', label: 'Completed'),
    ];

    final parsedStageStatuses = toOptionList(json['stage_status'] ?? json['stage_statuses']);
    final defaultStageStatuses = const [
      MetaOption(value: 'pending', label: 'Pending'),
      MetaOption(value: 'active', label: 'Active'),
      MetaOption(value: 'completed', label: 'Completed'),
    ];

    return TournamentMetaModel(
      modes: toOptionList(json['modes']),
      tournamentTypes: toOptionList(json['tournament_types']),
      playerRoles: toOptionList(json['player_roles']),
      stageTypes: toOptionList(json['stage_types']),
      leaderboardTypes: toOptionList(json['leaderboard_types']),
      statuses: parsedStatuses.isNotEmpty ? parsedStatuses : defaultStatuses,
      stageStatuses: parsedStageStatuses.isNotEmpty ? parsedStageStatuses : defaultStageStatuses,
    );
  }

  TournamentMetaEntity toEntity() => TournamentMetaEntity(
        modes: modes,
        tournamentTypes: tournamentTypes,
        playerRoles: playerRoles,
        stageTypes: stageTypes,
        leaderboardTypes: leaderboardTypes,
        statuses: statuses,
        stageStatuses: stageStatuses,
      );
}
