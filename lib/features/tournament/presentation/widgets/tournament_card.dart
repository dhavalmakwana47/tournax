import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/route_args.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tournament_entity.dart';
import 'tournament_action_button.dart';
import 'tournament_badge.dart';
import 'tournament_popup_menu.dart';
import 'tournament_progress_bar.dart';
import 'tournament_stat_card.dart';

import 'package:tournax/core/widgets/app_cached_network_image.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({super.key, required this.tournament});

  final TournamentEntity tournament;

  // Curated esports game artwork URLs based on tournament ID / title / mode
  static const List<String> _bannerImages = [
    'https://tournax.in/tournament_bg/bgmi_notext_1.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_2.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_3.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_4.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_5.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_6.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_7.png', // Champions Trophy
    'https://tournax.in/tournament_bg/bgmi_notext_8.png', // Champions Trophy
  ];

  String get _bannerUrl {
    final index = (tournament.id.abs()) % _bannerImages.length;
    return _bannerImages[index];
  }

  // Derive dynamic stage & progress from API stages object
  (String stageText, double percent) get _stageProgress {
    if (tournament.stages != null) {
      final stages = tournament.stages!;
      final completed = stages.completed;
      final total = stages.total;
      final percent = (stages.completedPercentage / 100.0).clamp(0.0, 1.0);
      return ('$completed/$total', percent);
    }
    switch (tournament.status.toLowerCase()) {
      case 'draft':
        return ('0/0', 0.0);
      case 'upcoming':
        return ('0/0', 0.0);
      case 'live':
      case 'active':
      case 'ongoing':
        return ('0/0', 0.0);
      case 'completed':
      case 'finished':
      default:
        return ('0/0', 1.0);
    }
  }

  // Fourth stat card calculation
  (IconData icon, String value, String label, Color? color) get _fourthStat {
    if (tournament.stages != null) {
      final percentage = tournament.stages!.completedPercentage;
      final formatted = percentage.truncateToDouble() == percentage
          ? percentage.toStringAsFixed(0)
          : percentage.toStringAsFixed(1);
      return (
        Icons.trending_up_rounded,
        '$formatted%',
        'Progress',
        AppColors.success,
      );
    }
    switch (tournament.status.toLowerCase()) {
      case 'draft':
        return (Icons.trending_up_rounded, '--', 'Progress', AppColors.success);
      case 'published':
      case 'upcoming':
        return (
          Icons.calendar_month_rounded,
          'Published',
          'Status',
          AppColors.upcomingStatus
        );
      case 'live':
      case 'active':
      case 'ongoing':
        return (
          Icons.sensors_rounded,
          'LIVE',
          'In Progress',
          AppColors.liveStatus
        );
      case 'completed':
      case 'finished':
        return (
          Icons.emoji_events_rounded,
          'Completed',
          'Final Result',
          AppColors.warning
        );
      default:
        return (
          Icons.sports_esports_rounded,
          tournament.status.toUpperCase(),
          'Status',
          AppColors.primary,
        );
    }
  }

  void _onPrimaryAction(BuildContext context) {
    switch (tournament.status.toLowerCase()) {
      case 'draft':
      case 'published':
      case 'upcoming':
      case 'live':
      case 'active':
      case 'ongoing':
        context.pushNamed(
          AppRoutes.stageList,
          extra: StageArgs(tournament: tournament),
        );
        break;
      case 'completed':
      case 'finished':
        context.pushNamed(
          AppRoutes.leaderboard,
          extra: LeaderboardArgs(
            tournament: tournament,
            type: LeaderboardType.tournament,
            id: tournament.id,
            name: tournament.name,
          ),
        );
        break;
      default:
        context.pushNamed(
          AppRoutes.stageList,
          extra: StageArgs(tournament: tournament),
        );
        break;
    }
  }

  void _onMenuAction(BuildContext context, TournamentAction action) {
    switch (action) {
      case TournamentAction.edit:
        context.pushNamed(
          AppRoutes.editTournament,
          extra: EditTournamentArgs(tournamentId: tournament.id),
        );
        break;
      case TournamentAction.addTeams:
        context.pushNamed(
          AppRoutes.teamList,
          extra: tournament,
        );
        break;
      case TournamentAction.leaderboard:
        context.pushNamed(
          AppRoutes.leaderboard,
          extra: LeaderboardArgs(
            tournament: tournament,
            type: LeaderboardType.tournament,
            id: tournament.id,
            name: tournament.name,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (stageText, progressPercent) = _stageProgress;
    final (statIcon, statVal, statLabel, statColor) = _fourthStat;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Section (~30% width): Tournament Banner Artwork
              Expanded(
                flex: 30,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppCachedNetworkImage(
                      imageUrl: _bannerUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.surface, AppColors.cardBackground],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sports_esports_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    // Dark gradient overlay for smooth visual blending
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.cardBackground.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Section (~70% width): Tournament Content
              Expanded(
                flex: 70,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Status Badge + 3-Dot Popup Menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TournamentBadge(status: tournament.status),
                          TournamentPopupMenu(
                            onSelected: (action) => _onMenuAction(context, action),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Tournament Title
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Tournament Info Row: Mode | Type | Start Date (Scrollable if screen is tight)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sports_esports_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tournament.mode.toUpperCase(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '|',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.account_tree_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tournament.tournamentType
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                            if (tournament.startDate != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '|',
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateShort(tournament.startDate!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Statistics Grid (4 Cards in 2x2 layout)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TournamentStatCard(
                                  icon: Icons.groups_rounded,
                                  value: '${tournament.maxTeams}',
                                  label: 'Max teams',
                                  iconColor: AppColors.draftStatus,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TournamentStatCard(
                                  icon: Icons.sports_esports_rounded,
                                  value: tournament.mode.toUpperCase(),
                                  label: 'Mode',
                                  iconColor: AppColors.upcomingStatus,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TournamentStatCard(
                                  icon: Icons.calendar_today_rounded,
                                  value: _formatDateDayMonth(
                                      tournament.startDate),
                                  label: 'Start Date',
                                  iconColor: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TournamentStatCard(
                                  icon: statIcon,
                                  value: statVal,
                                  label: statLabel,
                                  iconColor: statColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tournament Progress + Primary Action Button Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TournamentProgressBar(
                              status: tournament.status,
                              stageText: stageText,
                              progressPercent: progressPercent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          TournamentActionButton(
                            status: tournament.status,
                            onPressed: () => _onPrimaryAction(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateShort(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatDateDayMonth(String? iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return iso;
    }
  }
}
