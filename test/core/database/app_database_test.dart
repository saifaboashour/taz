import 'package:async/async.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taz/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('should insert and retrieve a habit', () async {
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
  });

  test('should emit updated habits when database changes', () async {
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
  });
}
