import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_otp_page.dart';
import '../../features/authentication/presentation/pages/reset_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/domain/entities/profile_entity.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/tournament/presentation/pages/tournament_list_page.dart';
import '../../features/tournament/presentation/pages/create_tournament_page.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordOtp = '/forgot-password-otp';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String tournaments = '/tournaments';
  static const String createTournament = '/tournaments/create';
}

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(String? initialToken) : _token = initialToken;

  String? _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }
}

late final AuthNotifier authNotifier;

final _publicRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.otpVerification,
  AppRoutes.forgotPassword,
  AppRoutes.forgotPasswordOtp,
  AppRoutes.resetPassword,
};

GoRouter buildRouter(Ref ref, String? initialToken) {
  authNotifier = AuthNotifier(initialToken);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isPublic = _publicRoutes.contains(state.matchedLocation);
      if (authNotifier.isAuthenticated && isPublic) return AppRoutes.home;
      if (!authNotifier.isAuthenticated && !isPublic) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: AppRoutes.otpVerification,
        builder: (context, state) => OtpVerificationPage(
          email: state.extra as String,
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        name: AppRoutes.forgotPasswordOtp,
        builder: (context, state) => const ForgotPasswordOtpPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRoutes.editProfile,
        builder: (context, state) => EditProfilePage(
          profile: state.extra as ProfileEntity,
        ),
      ),
      GoRoute(
        path: AppRoutes.tournaments,
        name: AppRoutes.tournaments,
        builder: (context, state) => const TournamentListPage(),
      ),
      GoRoute(
        path: AppRoutes.createTournament,
        name: AppRoutes.createTournament,
        builder: (context, state) => const CreateTournamentPage(),
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final initialToken = ref.read(initialTokenProvider);
  return buildRouter(ref, initialToken);
});

final initialTokenProvider = Provider<String?>((ref) => null);
