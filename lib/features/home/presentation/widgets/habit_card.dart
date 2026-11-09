import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/app/theme/app_text_styles.dart';
import 'package:taz/core/widgets/app_card.dart';

import 'habit_completion_indicator.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  final String title;
  final String description;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Expanded(
            child: Column(
              spacing: AppSpacing.sm,
              crossAxisAlignment: .start,
              children: [
                Text(title, style: AppTextStyles.habitTitle),
                Text(description, style: AppTextStyles.subtitle),
              ],
            ),
          ),
          HabitCompletionIndicator(isCompleted: isCompleted),
        ],
      ),
    );
  }
}
