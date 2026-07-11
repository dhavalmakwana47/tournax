import '../../domain/entities/tournament_meta_entity.dart';

class TournamentMetaModel {
  const TournamentMetaModel({
    required this.modes,
    required this.tournamentTypes,
  });

  final List<MetaOption> modes;
  final List<MetaOption> tournamentTypes;

  factory TournamentMetaModel.fromJson(Map<String, dynamic> json) {
    List<MetaOption> _toOptionList(dynamic raw) {
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
      modes: _toOptionList(json['modes']),
      tournamentTypes: _toOptionList(json['tournament_types']),
    );
  }

  TournamentMetaEntity toEntity() => TournamentMetaEntity(
        modes: modes,
        tournamentTypes: tournamentTypes,
      );
}
