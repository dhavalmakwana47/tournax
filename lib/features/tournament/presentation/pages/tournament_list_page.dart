import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tournament_entity.dart';
import '../controller/tournament_controller.dart';
import '../widgets/tournament_card.dart';
import '../widgets/tournament_header.dart';
import '../widgets/tournament_search_bar.dart';
import '../widgets/tournament_status_chip.dart';

class TournamentListPage extends ConsumerStatefulWidget {
  const TournamentListPage({super.key});

  @override
  ConsumerState<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends ConsumerState<TournamentListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  String _selectedStatus = 'All';
  String _selectedSort = 'Newest';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTournamentsFromApi();
      ref.read(tournamentControllerProvider.notifier).fetchTournamentMeta(forceRefresh: true);
    });
  }

  void _fetchTournamentsFromApi() {
    final statusParam =
        _selectedStatus.toLowerCase() == 'all' ? null : _selectedStatus;
    ref.read(tournamentControllerProvider.notifier).fetchTournaments(
          status: statusParam,
        );
  }

  void _onSearchQueryChanged(String q) {
    setState(() => _searchQuery = q);
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchTournamentsFromApi();
    });
  }

  void _onStatusSelected(String status) {
    setState(() => _selectedStatus = status);
    _fetchTournamentsFromApi();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      ref.read(tournamentControllerProvider.notifier).fetchMoreTournaments();
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<TournamentEntity> _filterAndSort(List<TournamentEntity> tournaments) {
    var filtered = tournaments.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.mode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.tournamentType.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatus.toLowerCase() == 'all' ||
          t.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();

    switch (_selectedSort) {
      case 'Oldest':
        filtered.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'Recently Updated':
        filtered.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
        break;
      case 'Newest':
      default:
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed top controls: Search Bar & Status Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: TournamentSearchBar(
                controller: _searchController,
                onChanged: _onSearchQueryChanged,
                onFilterTap: () => _showFilterBottomSheet(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: TournamentStatusFilterRow(
                selectedStatus: _selectedStatus,
                statusOptions: state.meta?.statuses,
                onStatusSelected: _onStatusSelected,
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),

            // Content Body: List Header + Tournaments List
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TournamentState state) {
    return switch (state.listStatus) {
      TournamentListStatus.initial || TournamentListStatus.loading =>
        _buildSkeletonLoader(),
      TournamentListStatus.empty => _EmptyState(
          onRetry: () => ref
              .read(tournamentControllerProvider.notifier)
              .fetchTournaments(),
        ),
      TournamentListStatus.error => _ErrorState(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref
              .read(tournamentControllerProvider.notifier)
              .fetchTournaments(),
        ),
      TournamentListStatus.success => _buildTournamentList(state.tournaments),
    };
  }

  Widget _buildTournamentList(List<TournamentEntity> rawTournaments) {
    final displayedTournaments = _filterAndSort(rawTournaments);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () =>
          ref.read(tournamentControllerProvider.notifier).fetchTournaments(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: TournamentHeader(
                count: displayedTournaments.length,
                selectedSort: _selectedSort,
                onSortChanged: (sort) => setState(() => _selectedSort = sort),
              ),
            ),
          ),
          if (displayedTournaments.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBorder.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No matching tournaments found',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Try clearing search or changing the status filter.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedStatus = 'All';
                          });
                          _fetchTournamentsFromApi();
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Reset Filters',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tournament = displayedTournaments[index];
                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      opacity: 1.0,
                      child: TournamentCard(tournament: tournament),
                    );
                  },
                  childCount: displayedTournaments.length,
                ),
              ),
            ),
          if (ref.watch(tournamentControllerProvider).isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 110,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 60, height: 16, color: AppColors.surface),
                    const SizedBox(height: 8),
                    Container(width: 140, height: 20, color: AppColors.surface),
                    const SizedBox(height: 12),
                    Container(
                        width: double.infinity,
                        height: 30,
                        color: AppColors.surface),
                    const Spacer(),
                    Container(
                        width: double.infinity,
                        height: 12,
                        color: AppColors.surface),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Tournaments',
                  style: AppTextStyles.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Status Filter', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TournamentStatusFilterRow(
              selectedStatus: _selectedStatus,
              onStatusSelected: (status) {
                setState(() => _selectedStatus = status);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.cardBorder.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No Tournaments Found',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create your first esports tournament using the + button or refresh to reload.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Refresh List',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
