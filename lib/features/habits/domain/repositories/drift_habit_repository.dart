import 'package:drift/drift.dart' show Value;
import 'package:rxdart/rxdart.dart';
import 'package:taz/core/database/app_database.dart';
import 'package:taz/features/habits/domain/models/habit.dart' as domain;
import 'package:taz/features/habits/domain/repositories/habit_repository.dart';

class DriftHabitRepository implements HabitRepository {
  final AppDatabase database;

  DriftHabitRepository(this.database);

  @override
  Future<void> addHabit(domain.Habit habit) async {
    final companion = HabitsCompanion.insert(
      id: habit.id,
      title: habit.title,
      description: Value(habit.description),
    );

    await database.insertHabit(companion);
  }

  @override
  Stream<List<domain.Habit>> watchHabits() {
    final habitsStream = database.watchAllHabits();

    final completionsStream = database.watchCompletionsForDate(DateTime.now());

    return Rx.combineLatest2(habitsStream, completionsStream, (
      habits,
      completions,
    ) {
      final Set<String> completedHabitIds = completions
          .map((completion) => completion.habitId)
          .toSet();
      return habits.map((habit) {
        return domain.Habit(
          id: habit.id,
          title: habit.title,
          description: habit.description ?? '',
          isCompleted: completedHabitIds.contains(habit.id),
        );
      }).toList();
    });
  }

  @override
  Future<void> completeHabit(String habitId, DateTime date) async {
    final companion = HabitCompletionsCompanion(
      habitId: Value(habitId),
      date: Value(date),
    );

    await database.insertHabitCompletion(companion);
  }

  @override
  Future<void> uncompleteHabit(String habitId, DateTime date) async {
    await database.deleteHabitCompletion(habitId, date);
  }
}
