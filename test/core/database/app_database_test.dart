import 'package:async/async.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:taz/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  test('should insert and retrieve a habit', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    await database.insertHabit(companion);

    final habits = await database.getAllHabits();

    expect(habits.length, 1);

    expect(habits.first.id, 'habit-1');
    expect(habits.first.title, 'Morning Walk');
    expect(habits.first.description, 'Walk for 30 minutes');
    expect(habits.first.createdAt, isA<DateTime>());

    await database.close();
  });

  test('should emit updated habits when database changes', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion1 = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    final companion2 = HabitsCompanion.insert(
      id: 'habit-2',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    final queue = StreamQueue(database.watchAllHabits());

    try {
      final initialHabits = await queue.next;
      expect(initialHabits, isEmpty);

      await database.insertHabit(companion1);

      final updatedHabits = await queue.next;

      expect(updatedHabits.length, 1);
      expect(updatedHabits.first.id, 'habit-1');

      await database.insertHabit(companion2);

      final updatedHabits2 = await queue.next;

      expect(updatedHabits2.length, 2);
      expect(updatedHabits2.last.id, 'habit-2');
    } finally {
      await queue.cancel();
    }

    await database.close();
  });

  test(
    'migrates database from version 1 to version 2 without losing habits',
    () async {
      final connection = sqlite.sqlite3.openInMemory();

      connection.execute('''
        CREATE TABLE habits (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');

      connection.execute('PRAGMA user_version = 1');

      connection.execute(
        'INSERT INTO habits (id, title, description) VALUES (?, ?, ?)',
        ['habit-1', 'Morning Walk', 'Walk for 30 minutes'],
      );

      final executor = NativeDatabase.opened(connection);

      final migratedDatabase = AppDatabase(executor);
      final habits = await migratedDatabase.getAllHabits();

      expect(habits.length, 1);
      expect(habits.first.id, 'habit-1');
      expect(habits.first.title, 'Morning Walk');

      final versionRow = await migratedDatabase
          .customSelect('PRAGMA user_version;')
          .getSingle();

      final version = versionRow.read<int>('user_version');

      expect(version, 2);

      final tableRow = await migratedDatabase
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'habit_completions';",
          )
          .getSingleOrNull();

      expect(tableRow, isNotNull);

      await migratedDatabase.close();
    },
  );

  test('should insert a habit completion', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    await database.insertHabit(companion);

    final habitCompletionCompanion = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14)),
    );

    final result = await database.insertHabitCompletion(
      habitCompletionCompanion,
    );

    expect(result, isPositive);

    await database.close();
  });

  test('should ignore duplicate habit completions', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    await database.insertHabit(companion);

    final habitCompletionCompanion = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14)),
    );

    await database.insertHabitCompletion(habitCompletionCompanion);

    await database.insertHabitCompletion(habitCompletionCompanion);

    final result = await database.getHabitCompletions('habit-1');

    expect(result.length, 1);
    expect(result.first.date, DateTime(2026, 11, 14));

    await database.close();
  });

  test('should ignore completions on the same calendar day', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    await database.insertHabit(companion);

    final habitCompletionCompanion = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14, 8)),
    );

    final result = await database.insertHabitCompletion(
      habitCompletionCompanion,
    );

    expect(result, isPositive);

    final sameDayHabitCompletionCompanion = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14, 20)),
    );

    await database.insertHabitCompletion(sameDayHabitCompletionCompanion);

    final result2 = await database.getHabitCompletions('habit-1');

    expect(result2.length, 1);
    expect(result2.first.date, DateTime(2026, 11, 14));

    await database.close();
  });

  test('should retrieve completions for a specific habit', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    final companion2 = HabitsCompanion.insert(
      id: 'habit-2',
      title: 'Drink Water',
      description: Value('Drink 4 cups per day'),
    );

    await database.insertHabit(companion);

    await database.insertHabit(companion2);

    final habitCompletionCompanion1 = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 12)),
    );

    final habitCompletionCompanion2 = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 13)),
    );

    final habitCompletionCompanion3 = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14)),
    );

    final habitCompletionCompanion4 = HabitCompletionsCompanion(
      habitId: Value('habit-2'),
      date: Value(DateTime(2026, 11, 14)),
    );

    await database.insertHabitCompletion(habitCompletionCompanion1);
    await database.insertHabitCompletion(habitCompletionCompanion2);
    await database.insertHabitCompletion(habitCompletionCompanion3);
    await database.insertHabitCompletion(habitCompletionCompanion4);

    final result = await database.getHabitCompletions('habit-1');

    expect(result.length, 3);

    expect(
      result.every((completion) => completion.habitId == 'habit-1'),
      isTrue,
    );

    await database.close();
  });

  test('should emit updated habit completions when database changes', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion1 = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    final habitCompletionCompanion = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14)),
    );

    await database.insertHabit(companion1);

    final queue = StreamQueue(database.watchHabitCompletions('habit-1'));

    try {
      final initialHabitCompletions = await queue.next;
      expect(initialHabitCompletions, isEmpty);

      await database.insertHabitCompletion(habitCompletionCompanion);

      final updatedHabitCompletions = await queue.next;

      expect(updatedHabitCompletions.length, 1);
      expect(updatedHabitCompletions.first.habitId, 'habit-1');
    } finally {
      await queue.cancel();
    }

    await database.close();
  });

  test('should delete only the specified habit completion', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    final companion2 = HabitsCompanion.insert(
      id: 'habit-2',
      title: 'Drink Water',
      description: Value('Drink 4 cups per day'),
    );

    await database.insertHabit(companion);

    await database.insertHabit(companion2);

    final habitCompletionCompanion1 = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 13)),
    );

    final habitCompletionCompanion2 = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14)),
    );

    final habitCompletionCompanion3 = HabitCompletionsCompanion(
      habitId: Value('habit-2'),
      date: Value(DateTime(2026, 11, 14)),
    );

    await database.insertHabitCompletion(habitCompletionCompanion1);
    await database.insertHabitCompletion(habitCompletionCompanion2);
    await database.insertHabitCompletion(habitCompletionCompanion3);

    final result = await database.getHabitCompletions('habit-1');

    expect(result.length, 2);

    await database.deleteHabitCompletion('habit-1', DateTime(2026, 11, 14));

    final updatedResult = await database.getHabitCompletions('habit-1');

    expect(updatedResult.length, 1);

    await database.close();
  });

  test('should return zero when deleting a nonexistent completion', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    await database.insertHabit(companion);

    final result = await database.deleteHabitCompletion(
      'habit-1',
      DateTime(2026, 11, 14),
    );

    expect(result, 0);

    await database.close();
  });

  test('should emit completions for the specified date', () async {
    database = AppDatabase(NativeDatabase.memory());

    final companion = HabitsCompanion.insert(
      id: 'habit-1',
      title: 'Morning Walk',
      description: Value('Walk for 30 minutes'),
    );

    final companion2 = HabitsCompanion.insert(
      id: 'habit-2',
      title: 'Drink Water',
      description: Value('Drink 4 cups per day'),
    );

    await database.insertHabit(companion);

    await database.insertHabit(companion2);

    final queue = StreamQueue(
      database.watchCompletionsForDate(DateTime(2026, 11, 14, 18)),
    );

    final habitCompletionCompanion1 = HabitCompletionsCompanion(
      habitId: Value('habit-1'),
      date: Value(DateTime(2026, 11, 14)),
    );

    final habitCompletionCompanion2 = HabitCompletionsCompanion(
      habitId: Value('habit-2'),
      date: Value(DateTime(2026, 11, 14)),
    );

    try {
      final initialHabitCompletions = await queue.next;
      expect(initialHabitCompletions, isEmpty);

      await database.insertHabitCompletion(habitCompletionCompanion1);

      final updatedHabitCompletions = await queue.next;

      expect(updatedHabitCompletions.length, 1);
      expect(updatedHabitCompletions.first.habitId, 'habit-1');

      await database.insertHabitCompletion(habitCompletionCompanion2);

      final updatedHabitCompletions2 = await queue.next;

      expect(updatedHabitCompletions2.length, 2);
      expect(updatedHabitCompletions2.last.habitId, 'habit-2');
    } finally {
      await queue.cancel();
    }

    await database.close();
  });
}
