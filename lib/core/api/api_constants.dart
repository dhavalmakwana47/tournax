abstract final class ApiConstants {
  static const String baseUrl = 'http://10.137.118.115:8000/api/v1';
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

  static String tournamentTeams(int tournamentId) =>
      '/tournaments/$tournamentId/teams';

  static String tournamentTeam(int tournamentId, int teamId) =>
      '/tournaments/$tournamentId/teams/$teamId';

  static String tournamentTeamPlayers(int tournamentId, int teamId) =>
      '/tournaments/$tournamentId/teams/$teamId/players';

  static String tournamentTeamPlayer(
          int tournamentId, int teamId, int playerId) =>
      '/tournaments/$tournamentId/teams/$teamId/players/$playerId';

  static const String playersSearch = '/players/search';

  static const String stages = '/stages';
  static const String stagesList = '/stages/list';
  static const String stagesShow = '/stages/show';
  static const String stagesUpdate = '/stages/update';
  static const String stagesDelete = '/stages/delete';
}
