import 'package:drift/drift.dart';

import 'habits_table.dart';

class HabitCompletions extends Table {
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {habitId, date};
}
