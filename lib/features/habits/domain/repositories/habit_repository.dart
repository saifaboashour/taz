import 'package:taz/features/habits/domain/models/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> watchHabits();

  Future<void> addHabit(Habit habit);
}
