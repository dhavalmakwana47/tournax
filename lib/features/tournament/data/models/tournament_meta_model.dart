import '../../domain/entities/tournament_meta_entity.dart';

class TournamentMetaModel {
  const TournamentMetaModel({
    required this.modes,
    required this.tournamentTypes,
    required this.playerRoles,
    this.stageTypes = const [],
    this.leaderboardTypes = const [],
  });

  final List<MetaOption> modes;
  final List<MetaOption> tournamentTypes;
  final List<MetaOption> playerRoles;
  final List<MetaOption> stageTypes;
  final List<MetaOption> leaderboardTypes;

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

    return TournamentMetaModel(
      modes: toOptionList(json['modes']),
      tournamentTypes: toOptionList(json['tournament_types']),
      playerRoles: toOptionList(json['player_roles']),
      stageTypes: toOptionList(json['stage_types']),
      leaderboardTypes: toOptionList(json['leaderboard_types']),
    );
  }

  TournamentMetaEntity toEntity() => TournamentMetaEntity(
        modes: modes,
        tournamentTypes: tournamentTypes,
        playerRoles: playerRoles,
        stageTypes: stageTypes,
        leaderboardTypes: leaderboardTypes,
      );
}
