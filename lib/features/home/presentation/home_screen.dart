import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/app/theme/app_text_styles.dart';
import 'package:taz/core/widgets/app_card.dart';
import 'package:taz/features/home/presentation/widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: .start,
            spacing: AppSpacing.xl,
            children: [
              HomeHeader(),
              AppCard(
                child: Column(
                  spacing: AppSpacing.sm,
                  crossAxisAlignment: .start,
                  children: [
                    Text('Walk', style: AppTextStyles.habitTitle),
                    Text(
                      'Goal · 4,000 steps / 3 days a week',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
