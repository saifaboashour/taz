import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_colors.dart';
import 'package:taz/app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}
