import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/player_tournament_controller.dart';
import '../widgets/tournament_card.dart';
import '../widgets/tournament_search_bar.dart';
import '../widgets/tournament_status_chip.dart';

class PlayerTournamentListPage extends ConsumerStatefulWidget {
  const PlayerTournamentListPage({super.key});

  @override
  ConsumerState<PlayerTournamentListPage> createState() =>
      _PlayerTournamentListPageState();
}

class _PlayerTournamentListPageState
    extends ConsumerState<PlayerTournamentListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  String _selectedStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(playerTournamentControllerProvider.notifier)
          .fetchPublicTournaments();
    });
  }

  void _fetchTournaments({bool refresh = true}) {
    final notifier = ref.read(playerTournamentControllerProvider.notifier);
    final currentTab =
        ref.read(playerTournamentControllerProvider).selectedTab;

    final statusParam = _selectedStatus.toLowerCase() == 'all'
        ? null
        : _selectedStatus.toLowerCase();

    if (currentTab == 0) {
      notifier.fetchPublicTournaments(
        refresh: refresh,
        status: statusParam,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } else {
      notifier.fetchParticipatedTournaments(
        refresh: refresh,
        status: statusParam,
      );
    }
  }

  void _onSearchQueryChanged(String q) {
    setState(() => _searchQuery = q);
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchTournaments();
    });
  }

  void _onStatusSelected(String status) {
    setState(() => _selectedStatus = status);
    _fetchTournaments();
  }

  Color _statusDotColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return AppColors.upcomingStatus;
      case 'live':
        return AppColors.liveStatus;
      case 'completed':
        return AppColors.completedStatus;
      default:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerTournamentControllerProvider);
    final notifier = ref.read(playerTournamentControllerProvider.notifier);

    final currentList = state.selectedTab == 0
        ? state.tournaments
        : state.participatedTournaments;

    return RefreshIndicator(
      onRefresh: () async => _fetchTournaments(),
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      child: Column(
        children: [
          // Sub-header with Tab Selector
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SegmentedTabButton(
                        title: 'Public Tournaments',
                        icon: Icons.public_rounded,
                        isSelected: state.selectedTab == 0,
                        onTap: () {
                          notifier.selectTab(0);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SegmentedTabButton(
                        title: 'My Participated',
                        icon: Icons.sports_esports_rounded,
                        isSelected: state.selectedTab == 1,
                        onTap: () {
                          notifier.selectTab(1);
                        },
                      ),
                    ),
                  ],
                ),
                if (state.selectedTab == 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  TournamentSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchQueryChanged,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final status in [
                        'All',
                        'Published',
                        'Live',
                        'Completed'
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: TournamentStatusChip(
                            label: status,
                            dotColor: _statusDotColor(status),
                            isSelected: _selectedStatus == status,
                            onTap: () => _onStatusSelected(status),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(state, currentList),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      PlayerTournamentState state, List<TournamentEntity> list) {
    if (state.status == PlayerTournamentStatus.loading && list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == PlayerTournamentStatus.error && list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.errorMessage ?? 'Failed to load tournaments.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _fetchTournaments,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_outlined,
                  color: AppColors.textSecondary, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.selectedTab == 0
                    ? 'No public tournaments found'
                    : 'You have not joined any tournaments yet',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                state.selectedTab == 0
                    ? 'Check back later for newly announced tournaments!'
                    : 'Explore public tournaments and register your team.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tournament = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TournamentCard(tournament: tournament, isOrganizer: false),
        );
      },
    );
  }
}

class _SegmentedTabButton extends StatelessWidget {
  const _SegmentedTabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
