import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:taz/features/habits/data/local/tables/habits_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  Future<int> insertHabit(HabitsCompanion habit) {
    return into(habits).insert(habit);
  }

  Future<List<Habit>> getAllHabits() {
    return select(habits).get();
  }

  Stream<List<Habit>> watchAllHabits() {
    return select(habits).watch();
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(p.join(directory.path, 'taz.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
