import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:taz/features/habits/data/local/tables/habit_completions_table.dart';
import 'package:taz/features/habits/data/local/tables/habits_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits, HabitCompletions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  //Habits
  Future<int> insertHabit(HabitsCompanion habit) {
    return into(habits).insert(habit);
  }

  Future<List<Habit>> getAllHabits() {
    return select(habits).get();
  }

  Stream<List<Habit>> watchAllHabits() {
    return select(habits).watch();
  }

  //Habit Completion
  Future<int> insertHabitCompletion(HabitCompletionsCompanion completion) {
    final DateTime originalDate = completion.date.value;
    final DateTime normalizedDate = _normalizeDate(originalDate);
    return into(habitCompletions).insert(
      HabitCompletionsCompanion(
        habitId: completion.habitId,
        date: Value(normalizedDate),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<List<HabitCompletion>> getHabitCompletions(String habitId) {
    return (select(
      habitCompletions,
    )..where((table) => table.habitId.equals(habitId))).get();
  }

  Stream<List<HabitCompletion>> watchHabitCompletions(String habitId) {
    return (select(
      habitCompletions,
    )..where((table) => table.habitId.equals(habitId))).watch();
  }

  Future<int> deleteHabitCompletion(String habitId, DateTime date) {
    return (delete(habitCompletions)..where(
          (table) =>
              table.habitId.equals(habitId) &
              table.date.equals(_normalizeDate(date)),
        ))
        .go();
  }

  Stream<List<HabitCompletion>> watchCompletionsForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return (select(
      habitCompletions,
    )..where((table) => table.date.equals(normalizedDate))).watch();
  }

  //Helpers
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(habitCompletions);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(p.join(directory.path, 'taz.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
