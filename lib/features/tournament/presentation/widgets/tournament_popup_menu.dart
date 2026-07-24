import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum TournamentAction { edit, leaderboard }

class TournamentPopupMenu extends StatelessWidget {
  const TournamentPopupMenu({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<TournamentAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TournamentAction>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
        size: 20,
      ),
      color: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _buildItem(
          value: TournamentAction.edit,
          icon: Icons.edit_outlined,
          label: 'Edit',
        ),
        _buildItem(
          value: TournamentAction.leaderboard,
          icon: Icons.emoji_events_outlined,
          label: 'Leaderboard',
        ),
      ],
    );
  }

  PopupMenuItem<TournamentAction> _buildItem({
    required TournamentAction value,
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return PopupMenuItem<TournamentAction>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
