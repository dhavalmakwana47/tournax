import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TournamentHeader extends StatelessWidget {
  const TournamentHeader({
    super.key,
    required this.count,
    required this.selectedSort,
    required this.onSortChanged,
  });

  final int count;
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  static const List<String> _sortOptions = [
    'Newest',
    'Oldest',
    'Recently Updated',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$count ${count == 1 ? "Tournament" : "Tournaments"}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.inputBorder.withValues(alpha: 0.8),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortOptions.contains(selectedSort)
                  ? selectedSort
                  : _sortOptions.first,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
              dropdownColor: AppColors.cardBackground,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              onChanged: (val) {
                if (val != null) onSortChanged(val);
              },
              items: _sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(option),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
