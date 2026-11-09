import 'package:flutter_test/flutter_test.dart';
import 'package:taz/features/habits/domain/models/habit.dart';

void main() {
  group('Basic Data Model Habit Tests', () {
    test('Default completion', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
      );

      //Assert
      expect(habit.isCompleted, false);
    });

    test('Explicit completion', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
        isCompleted: true,
      );

      //Assert
      expect(habit.isCompleted, true);
    });

    test('Copy and update', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
      );

      //Act
      Habit habit2 = habit.copyWith(isCompleted: true);

      //Assert
      expect(habit.isCompleted, false);
      expect(habit2.isCompleted, true);
      expect(habit2.id, habit.id);
      expect(habit2.title, habit.title);
      expect(habit2.description, habit.description);
    });

    test('Copy back to false', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
        isCompleted: true,
      );

      //Act
      Habit habit2 = habit.copyWith(isCompleted: false);

      //Assert
      expect(habit2.isCompleted, false);
    });

    test('Original unchanged', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
        isCompleted: true,
      );

      //Act
      habit.copyWith(isCompleted: false);

      //Assert
      expect(habit.isCompleted, true);
    });
  });

  group('Verify that copyWith handles all properties and creates independent instances.', () {
    test('Update multiple properties', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
      );

      //Act
      Habit habit2 = habit.copyWith(
        title: 'Test 2',
        description: 'This is just a test',
      );

      //Assert
      expect(habit2.isCompleted, habit.isCompleted);
      expect(habit2.id, habit.id);
      expect(habit2.title, 'Test 2');
      expect(habit2.description, 'This is just a test');
    });

    test('Copy without changes', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
      );

      //Act
      Habit habit2 = habit.copyWith();

      //Assert
      expect(habit2.isCompleted, habit.isCompleted);
      expect(habit2.id, habit.id);
      expect(habit2.title, habit.title);
      expect(habit2.description, habit.description);
    });

    test('New instance', () {
      //Arrange
      const Habit habit = Habit(
        id: '1',
        title: 'Test',
        description: 'This is a test',
      );

      //Act
      Habit habit2 = habit.copyWith(isCompleted: true);

      //Assert
      expect(identical(habit, habit2), isFalse);
    });
  });
}
