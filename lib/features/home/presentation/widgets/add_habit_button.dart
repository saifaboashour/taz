import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_colors.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/app/theme/app_text_styles.dart';

class AddHabitButton extends StatelessWidget {
  const AddHabitButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Row(
        spacing: AppSpacing.sm,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: AppColors.primaryAccent),
          Text(
            'Add Habit',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }
}
