abstract final class ApiConstants {
  // static const String baseUrl = 'https://tournax.in/api/v1';
  static const String baseUrl = 'http://10.167.110.115:8000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  static const String login = '/login';
  static const String logout = '/logout';
  static const String register = '/register';
  static const String verifyEmailOtp = '/verify-email-otp';
  static const String resendEmailOtp = '/resend-email-otp';
  static const String profile = '/profile';

  static const String forgotPassword = '/forgot-password';
  static const String verifyForgotPasswordOtp = '/verify-forgot-password-otp';
  static const String resetPassword = '/reset-password';

  static const String tournaments = '/tournaments';
  static const String tournamentsMeta = '/tournaments/meta';
  static const String tournamentsShow = '/tournaments/show';
  static const String tournamentsUpdate = '/tournaments/update';

  static String tournamentTeams(int tournamentId) =>
      '/tournaments/$tournamentId/teams';

  static String tournamentTeam(int tournamentId, int teamId) =>
      '/tournaments/$tournamentId/teams/$teamId';

  static String tournamentTeamPlayers(int tournamentId, int teamId) =>
      '/tournaments/$tournamentId/teams/$teamId/players';

  static String tournamentTeamPlayer(
    int tournamentId,
    int teamId,
    int playerId,
  ) => '/tournaments/$tournamentId/teams/$teamId/players/$playerId';

  static const String playersSearch = '/players/search';

  static const String stages = '/stages';
  static const String stagesList = '/stages/list';
  static const String stagesShow = '/stages/show';
  static const String stagesUpdate = '/stages/update';
  static const String stagesDelete = '/stages/delete';

  static const String rounds = '/rounds';
  static const String roundsList = '/rounds/list';
  static const String roundsShow = '/rounds/show';
  static const String roundsUpdate = '/rounds/update';
  static const String roundsDelete = '/rounds/delete';

  static const String groups = '/groups';
  static const String groupsList = '/groups/list';
  static const String groupsShow = '/groups/show';
  static const String groupsUpdate = '/groups/update';
  static const String groupsDelete = '/groups/delete';
  static const String groupsAddTeam = '/groups/add-team';
  static const String groupsRemoveTeam = '/groups/remove-team';

  static const String leaderboardGroup = '/leaderboard/group';
  static const String leaderboardRound = '/leaderboard/round';
  static const String leaderboardStage = '/leaderboard/stage';
  static const String leaderboardTournament = '/leaderboard/tournament';
  static const String leaderboardMatch = '/leaderboard/match';

  static const String matchesResultsStore = '/matches/results';
  static const String matchesResultsShow = '/matches/results/show';
  static const String matchesResultsDelete = '/matches/results/delete';
}
