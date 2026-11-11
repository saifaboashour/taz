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
}
