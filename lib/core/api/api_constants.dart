abstract final class ApiConstants {
//   static const String baseUrl = 'https://tournax.in/api/v1';
  static const String baseUrl = 'http://10.151.118.115:8000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  /// API Key configuration for backend middleware
  static const String apiKeyHeader = 'x-api-key';
  static const String apiKey = 'txx_9f4KqP7mN2vX8aL5RwY1JdEc6HsB3ZnU';

  // Public / Shared Auth & Profile Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String register = '/register';
  static const String verifyEmailOtp = '/verify-email-otp';
  static const String resendEmailOtp = '/resend-email-otp';
  static const String profile = '/profile';
  static const String sendDeleteAccountOtp = '/account/delete/send-otp';
  static const String confirmDeleteAccount = '/account/delete/confirm';

  static const String forgotPassword = '/forgot-password';
  static const String verifyForgotPasswordOtp = '/verify-forgot-password-otp';
  static const String resetPassword = '/reset-password';

  // Organizer Endpoints
  static const String tournaments = '/organizer/tournaments';
  static const String tournamentsMeta = '/organizer/tournaments/meta';
  static const String tournamentsShow = '/organizer/tournaments/show';
  static const String tournamentsUpdate = '/organizer/tournaments/update';

  static String tournamentTeams(int tournamentId) =>
      '/organizer/tournaments/$tournamentId/teams';

  static String tournamentTeam(int tournamentId, int teamId) =>
      '/organizer/tournaments/$tournamentId/teams/$teamId';

  static String tournamentTeamPlayers(int tournamentId, int teamId) =>
      '/organizer/tournaments/$tournamentId/teams/$teamId/players';

  static String tournamentTeamPlayer(
    int tournamentId,
    int teamId,
    int playerId,
  ) => '/organizer/tournaments/$tournamentId/teams/$teamId/players/$playerId';

  static const String playersSearch = '/organizer/players/search';

  static const String stages = '/organizer/stages';
  static const String stagesList = '/organizer/stages/list';
  static const String stagesShow = '/organizer/stages/show';
  static const String stagesUpdate = '/organizer/stages/update';
  static const String stagesDelete = '/organizer/stages/delete';

  static const String rounds = '/organizer/rounds';
  static const String roundsList = '/organizer/rounds/list';
  static const String roundsShow = '/organizer/rounds/show';
  static const String roundsUpdate = '/organizer/rounds/update';
  static const String roundsDelete = '/organizer/rounds/delete';

  static const String groups = '/organizer/groups';
  static const String groupsList = '/organizer/groups/list';
  static const String groupsShow = '/organizer/groups/show';
  static const String groupsUpdate = '/organizer/groups/update';
  static const String groupsDelete = '/organizer/groups/delete';
  static const String groupsAddTeam = '/organizer/groups/add-team';
  static const String groupsRemoveTeam = '/organizer/groups/remove-team';

  static const String matches = '/organizer/matches';
  static const String matchesList = '/organizer/matches/list';
  static const String matchesShow = '/organizer/matches/show';
  static const String matchesUpdate = '/organizer/matches/update';
  static const String matchesDelete = '/organizer/matches/delete';
  static const String matchesAddTeam = '/organizer/matches/add-team';
  static const String matchesRemoveTeam = '/organizer/matches/remove-team';

  static const String leaderboardGroup = '/organizer/leaderboard/group';
  static const String leaderboardRound = '/organizer/leaderboard/round';
  static const String leaderboardStage = '/organizer/leaderboard/stage';
  static const String leaderboardTournament =
      '/organizer/leaderboard/tournament';
  static const String leaderboardMatch = '/organizer/leaderboard/match';

  static const String matchesResultsStore = '/organizer/matches/results';
  static const String matchesResultsShow = '/organizer/matches/results/show';
  static const String matchesResultsDelete =
      '/organizer/matches/results/delete';

  static const String pointSystems = '/organizer/point-systems';
  static const String pointSystemsList = '/organizer/point-systems/list';
  static const String pointSystemsShow = '/organizer/point-systems/show';
  static const String pointSystemsUpdate = '/organizer/point-systems/update';
  static const String pointSystemsDelete = '/organizer/point-systems/delete';

  static const String templates = '/templates';

  // Player Endpoints
  static const String playerTournaments = '/player/tournaments';
  static const String playerTournamentsShow = '/player/tournaments/show';
  static const String playerTournamentsJoin = '/player/tournaments/join';
  static const String playerTournamentsLeave = '/player/tournaments/leave';
  static const String playerTournamentsParticipated =
      '/player/tournaments/participated';
}
