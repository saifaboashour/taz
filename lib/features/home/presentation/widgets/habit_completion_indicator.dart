import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_colors.dart';

class HabitCompletionIndicator extends StatelessWidget {
  const HabitCompletionIndicator({super.key, required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isCompleted ? 'Habit Completed' : 'Habit Not Completed',
      child: Container(
        height: 32,
        width: 32,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primaryAccent : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryAccent, width: 2)
        ),
        child: isCompleted ? Icon(Icons.check , color: AppColors.background,) : null,
      ),
    );
  }
}
