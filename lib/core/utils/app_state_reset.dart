import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../../features/profile/presentation/controller/profile_controller.dart';
import '../../features/tournament/presentation/controller/tournament_controller.dart';
import '../../features/tournament/presentation/controller/player_tournament_controller.dart';

/// Invalidates all user-specific Riverpod providers so that when a new user
/// logs in (or the current user logs out), no stale data from a previous
/// session remains in memory.
///
/// Call this:
///   • After a successful login  → clear any previous user's cached state.
///   • Before / after logout     → clear the current user's cached state.
void resetUserState(Ref ref) {
  ref.invalidate(profileControllerProvider);
  ref.invalidate(tournamentControllerProvider);
  ref.invalidate(playerTournamentControllerProvider);
  // Re-read role from storage so home screen shows correct tab for new user
  ref.invalidate(userRoleProvider);
}

/// Convenience helper when you only have access to a WidgetRef (e.g. in pages).
void resetUserStateFromWidget(WidgetRef ref) {
  ref.invalidate(profileControllerProvider);
  ref.invalidate(tournamentControllerProvider);
  ref.invalidate(playerTournamentControllerProvider);
  // Re-read role from storage so home screen shows correct tab for new user
  ref.invalidate(userRoleProvider);
}
