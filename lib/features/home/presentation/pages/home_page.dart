import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../authentication/presentation/controller/login_controller.dart';
import '../../../profile/presentation/controller/profile_controller.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../tournament/presentation/pages/organizer/tournament_list_page.dart';
import '../../../tournament/presentation/pages/player/player_tournament_list_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).fetch();
    });
  }

  bool _isOrganizer(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase();
    return r.contains('organizer') || r.contains('organiser');
  }

  @override
  Widget build(BuildContext context) {
    // --- Primary: role from SecureStorage (available instantly) ---
    final roleAsync = ref.watch(userRoleProvider);

    // --- Fallbacks from in-memory state (for cases where storage read is
    //     still in-flight, or after a same-session login) ---
    final profileRole = ref.watch(profileControllerProvider).profile?.role;
    final loginRole = ref.watch(loginControllerProvider).user?.role;

    // Resolve role: storage → profile API → login state → null (show loading)
    final resolvedRole = roleAsync.maybeWhen(
      data: (r) => r ?? profileRole ?? loginRole,
      orElse: () => profileRole ?? loginRole,
    );

    // While role is genuinely unknown (storage hasn't returned yet and no
    // in-memory fallback), show a minimal loading indicator so we never
    // accidentally flash the wrong screen.
    if (resolvedRole == null && roleAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isOrganizer = _isOrganizer(resolvedRole);

    final List<Widget> pages = [
      isOrganizer ? const TournamentListPage() : const PlayerTournamentListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex < pages.length ? _currentIndex : 0,
        children: pages,
      ),
      floatingActionButton: (isOrganizer && _currentIndex == 0)
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.createTournament),
              backgroundColor: AppColors.primary,
              elevation: 6,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.textPrimary,
                size: 30,
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavigationBar(isOrganizer),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.lg,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              AppAssets.logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.sports_esports_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOURNAX',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'COMPETE. RANK. CONQUER',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isOrganizer) {
    final firstTabLabel = isOrganizer ? 'Tournaments' : 'My Tournaments';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex < 2 ? _currentIndex : 0,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events_rounded),
            activeIcon: const Icon(Icons.emoji_events_rounded,
                color: AppColors.primary),
            label: firstTabLabel,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon:
                Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
