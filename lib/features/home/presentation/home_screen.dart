import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/features/home/presentation/widgets/habit_card.dart';
import 'package:taz/features/home/presentation/widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<(String,String,bool)> habits = [
    ('Walk', 'Goal · 4,000 steps / 3 days a week', false),
    ('Read', 'Goal · 20 minutes daily', true),
    ('Drink Water', 'Goal · 8 glasses daily', false),
    ('Exercise', 'Goal · 30 minutes / 4 days a week', true),
  ];

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
              Expanded(
                child: ListView.separated(
                  itemCount: habits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md,),
                  itemBuilder: (context,index) {
                    (String, String, bool) habit = habits[index];
                    return HabitCard(
                      title: habit.$1,
                      description:  habit.$2,
                      isCompleted: habit.$3,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
