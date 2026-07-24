import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class TournamentStatusFilterRow extends StatelessWidget {
  const TournamentStatusFilterRow({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  static const List<Map<String, dynamic>> _statuses = [
    {'label': 'All', 'color': AppColors.primary},
    {'label': 'Draft', 'color': AppColors.draftStatus},
    {'label': 'Upcoming', 'color': AppColors.upcomingStatus},
    {'label': 'Live', 'color': AppColors.liveStatus},
    {'label': 'Completed', 'color': AppColors.completedStatus},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _statuses.map((statusItem) {
          final label = statusItem['label'] as String;
          final dotColor = statusItem['color'] as Color;
          final isSelected = selectedStatus.toLowerCase() == label.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TournamentStatusChip(
              label: label,
              dotColor: dotColor,
              isSelected: isSelected,
              onTap: () => onStatusSelected(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TournamentStatusChip extends StatelessWidget {
  const TournamentStatusChip({
    super.key,
    required this.label,
    required this.dotColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color dotColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.inputFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.cardBorder.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? Colors.white : dotColor)
                            .withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
