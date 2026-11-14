import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_spacing.dart';
import 'package:taz/app/theme/app_text_styles.dart';
import 'package:taz/features/habits/domain/models/habit.dart';
import 'package:taz/features/habits/domain/repositories/habit_repository.dart';
import 'package:taz/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:taz/features/home/presentation/widgets/habit_card.dart';
import 'package:taz/features/home/presentation/widgets/habit_progress.dart';
import 'package:taz/features/home/presentation/widgets/home_header.dart';

import 'widgets/add_habit_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.habitRepository});

  final HabitRepository habitRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<Habit>> _habitsStream;

  final Set<String> _updatingHabitIds = {};
  bool _isSavingHabit = false;

  @override
  void initState() {
    super.initState();
    _habitsStream = widget.habitRepository.watchHabits();
  }

  void _addHabit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddHabitSheet(
          onSave: (String title, String description) async {
            final bool saved = await _saveHabit(title, description);
            if (saved && context.mounted) {
              Navigator.pop(context);
            }
          },
          onClose: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<bool> _saveHabit(String title, String description) async {
    if (_isSavingHabit) {
      return false;
    }
    try {
      _isSavingHabit = true;
      final habit = Habit(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: description,
      );

      await widget.habitRepository.addHabit(habit);

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save habit')));
      }
      return false;
    } finally {
      _isSavingHabit = false;
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    if (_updatingHabitIds.contains(habit.id)) {
      return;
    }
    try {
      final DateTime current = DateTime.now();

      _updatingHabitIds.add(habit.id);
      if (habit.isCompleted) {
        await widget.habitRepository.uncompleteHabit(habit.id, current);
      } else {
        await widget.habitRepository.completeHabit(habit.id, current);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update habit')));
      }
    } finally {
      _updatingHabitIds.remove(habit.id);
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
                child: StreamBuilder<List<Habit>>(
                  stream: _habitsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load habits'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final habits = snapshot.data!;

                    final completedCount = habits
                        .where((habit) => habit.isCompleted)
                        .length;

                    return Column(
                      children: [
                        HabitProgress(
                          completedCount: completedCount,
                          totalCount: habits.length,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Your Habits', style: AppTextStyles.header),
                            AddHabitButton(onTap: _addHabit),
                          ],
                        ),
                        Expanded(
                          child: habits.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No habits yet. Add your first habit!',
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: habits.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: AppSpacing.md),
                                  itemBuilder: (context, index) {
                                    final Habit habit = habits[index];
                                    return HabitCard(
                                      title: habit.title,
                                      description: habit.description,
                                      isCompleted: habit.isCompleted,
                                      onTap: () =>
                                          _toggleHabitCompletion(habit),
                                    );
                                  },
                                ),
                        ),
                      ],
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
