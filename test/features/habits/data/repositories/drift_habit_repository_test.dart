import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taz/core/database/app_database.dart';
import 'package:taz/features/habits/domain/models/habit.dart' as domain;
import 'package:taz/features/habits/domain/repositories/drift_habit_repository.dart';

void main() {
  late AppDatabase database;
  late DriftHabitRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftHabitRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('should persist and retrieve a domain habit', () async {
    final domain.Habit habit = domain.Habit(
      id: 'habit-1',
      title: 'Morning Walk',
      description: 'Walk for 30 minutes',
    );

    await repository.addHabit(habit);

    List<domain.Habit> result = await repository.watchHabits().first;

    expect(result.length, 1);
    expect(result.first.id, 'habit-1');
    expect(result.first.title, 'Morning Walk');
    expect(result.first.description, 'Walk for 30 minutes');
    expect(result.first.isCompleted, false);
  });

  test('should persist a habit completion through the repository', () async {
    final domain.Habit habit = domain.Habit(
      id: 'habit-1',
      title: 'Morning Walk',
      description: 'Walk for 30 minutes',
    );

    await repository.addHabit(habit);

    await repository.completeHabit('habit-1', DateTime(2026, 11, 14, 15));

    final result = await database.getHabitCompletions('habit-1');

    expect(result.length, 1);
    expect(result.first.habitId, 'habit-1');
    expect(result.first.date, DateTime(2026, 11, 14, 0));
  });

  test('should remove a habit completion through the repository', () async {
    final domain.Habit habit = domain.Habit(
      id: 'habit-1',
      title: 'Morning Walk',
      description: 'Walk for 30 minutes',
    );

    await repository.addHabit(habit);

    await repository.completeHabit('habit-1', DateTime(2026, 11, 14, 15));

    final result = await database.getHabitCompletions('habit-1');

    expect(result.length, 1);

    await repository.uncompleteHabit('habit-1', DateTime(2026, 11, 14, 20));

    final updatedResult = await database.getHabitCompletions('habit-1');

    expect(updatedResult, isEmpty);
  });

  test('should update habit completion state reactively', () async {
    final domain.Habit habit = domain.Habit(
      id: 'habit-1',
      title: 'Morning Walk',
      description: 'Walk for 30 minutes',
    );

    await repository.addHabit(habit);

    final queue = StreamQueue(repository.watchHabits());

    try {
      final result = await queue.next;
      expect(result.length, 1);
      expect(result.first.id, 'habit-1');
      expect(result.first.isCompleted, false);

      await repository.completeHabit('habit-1', DateTime.now());

      final updatedHabits = await queue.next;

      expect(updatedHabits.length, 1);
      expect(updatedHabits.first.isCompleted, true);

      await repository.uncompleteHabit('habit-1', DateTime.now());

      final updatedHabits2 = await queue.next;

      expect(updatedHabits2.length, 1);
      expect(updatedHabits2.first.isCompleted, false);
    } finally {
      await queue.cancel();
    }
  });
}
