import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/features/habits/domain/models/habit.dart';
import 'package:taz/features/home/presentation/widgets/habit_card.dart';
import 'package:taz/features/home/presentation/widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Habit> _habits = [
    Habit(
      id: '1',
      title: 'Walk',
      description: 'Goal · 4,000 steps / 3 days a week',
    ),
    Habit(
      id: '2',
      title: 'Read',
      description: 'Goal · 20 minutes daily',
      isCompleted: true,
    ),
    Habit(id: '3', title: 'Drink Water', description: 'Goal · 8 glasses daily'),
    Habit(
      id: '4',
      title: 'Exercise',
      description: 'Goal · 30 minutes / 4 days a week',
      isCompleted: true,
    ),
  ];

  void _toggleHabit(String habitId) {
    final int index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index >= 0) {
      setState(() {
        _habits[index] = _habits[index].copyWith(
          isCompleted: !_habits[index].isCompleted,
        );
      });
    }
  }

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
                  itemCount: _habits.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final Habit habit = _habits[index];
                    return HabitCard(
                      title: habit.title,
                      description: habit.description,
                      isCompleted: habit.isCompleted,
                      onTap: () => _toggleHabit(habit.id),
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
