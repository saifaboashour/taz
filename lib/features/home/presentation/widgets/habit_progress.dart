import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_colors.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/app/theme/app_text_styles.dart';
import 'package:taz/core/widgets/app_card.dart';

class HabitProgress extends StatelessWidget {
  const HabitProgress({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final double progressValue =
        (completedCount / (totalCount > 0 ? totalCount : 1)).clamp(0, 1);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Progress', style: AppTextStyles.header),
              Text(
                '$completedCount of $totalCount',
                style: AppTextStyles.header.copyWith(
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: progressValue,
            color: AppColors.primaryAccent,
            backgroundColor: AppColors.secondarySurface,
          ),
          Text(
            '${(progressValue * 100).round()}%',
            style: AppTextStyles.statLabel,
          ),
        ],
      ),
    );
  }
}
