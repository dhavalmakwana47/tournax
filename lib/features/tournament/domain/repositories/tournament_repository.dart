import '../entities/tournament_entity.dart';
import '../entities/tournament_meta_entity.dart';

class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
  });

  final List<T> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
}

abstract interface class TournamentRepository {
  Future<PaginatedResult<TournamentEntity>> getTournaments({
    int page = 1,
    int perPage = 5,
    String? status,
  });
  Future<TournamentEntity> createTournament({
    required String name,
    required String mode,
    required String tournamentType,
    required int maxTeams,
    required int maxPlayersPerTeam,
    required String startDate,
    required String endDate,
    String? description,
    String? registrationStart,
    String? registrationEnd,
    bool checkInEnabled,
    bool allowSubstitute,
    bool autoQualify,
    String? leaderboardType,
    String? rules,
    String? status,
  });
  Future<TournamentMetaEntity> getTournamentMeta();
  Future<TournamentEntity> showTournament(int tournamentId);
  Future<void> updateTournament(Map<String, dynamic> data);
}
