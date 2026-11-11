import 'package:drift/drift.dart' show Value;
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
    return database.watchAllHabits().map((habits) {
      return habits.map((habit) {
        return domain.Habit(
          id: habit.id,
          title: habit.title,
          description: habit.description ?? '',
          isCompleted: false,
        );
      }).toList();
    });
  }
}
