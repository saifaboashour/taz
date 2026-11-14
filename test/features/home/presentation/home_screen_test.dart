import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taz/core/database/app_database.dart';
import 'package:taz/features/habits/domain/models/habit.dart' as domain;
import 'package:taz/features/habits/domain/repositories/drift_habit_repository.dart';
import 'package:taz/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:taz/features/home/presentation/home_screen.dart';
import 'package:taz/features/home/presentation/widgets/add_habit_button.dart';
import 'package:taz/features/home/presentation/widgets/habit_card.dart';
import 'package:taz/features/home/presentation/widgets/habit_completion_indicator.dart';

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

  testWidgets(
    'Verify that tapping a habit\'s completion indicator updates its state correctly without changing other habits.',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(habitRepository: repository)),
      );

      expect(find.text('Add Habit'), findsOneWidget);

      expect(find.text('2 of 4'), findsOneWidget);

      expect(find.text('50%'), findsOneWidget);

      final progressFinder = find.byType(LinearProgressIndicator);

      final addHabitButtonFinder = find.byType(AddHabitButton);

      expect(tester.widget<LinearProgressIndicator>(progressFinder).value, 0.5);

      final walkCardFinder = find.ancestor(
        of: find.text('Walk'),
        matching: find.byType(HabitCard),
      );

      final walkIndicatorFinder = find.descendant(
        of: walkCardFinder,
        matching: find.byType(HabitCompletionIndicator),
      );

      expect(
        tester
            .widget<HabitCompletionIndicator>(walkIndicatorFinder)
            .isCompleted,
        isFalse,
      );

      await tester.tap(walkIndicatorFinder);

      await tester.pump();

      expect(
        tester
            .widget<HabitCompletionIndicator>(walkIndicatorFinder)
            .isCompleted,
        isTrue,
      );

      expect(find.text('3 of 4'), findsOneWidget);

      expect(find.text('75%'), findsOneWidget);

      expect(
        tester.widget<LinearProgressIndicator>(progressFinder).value,
        0.75,
      );

      await tester.tap(walkIndicatorFinder);

      await tester.pump();

      expect(
        tester
            .widget<HabitCompletionIndicator>(walkIndicatorFinder)
            .isCompleted,
        isFalse,
      );

      expect(find.text('2 of 4'), findsOneWidget);

      expect(find.text('50%'), findsOneWidget);

      expect(tester.widget<LinearProgressIndicator>(progressFinder).value, 0.5);

      final readCardFinder = find.ancestor(
        of: find.text('Read'),
        matching: find.byType(HabitCard),
      );

      final readIndicatorFinder = find.descendant(
        of: readCardFinder,
        matching: find.byType(HabitCompletionIndicator),
      );

      expect(
        tester
            .widget<HabitCompletionIndicator>(readIndicatorFinder)
            .isCompleted,
        isTrue,
      );

      await tester.tap(addHabitButtonFinder);

      await tester.pumpAndSettle();

      expect(find.text('Add Habit'), findsOneWidget);

      expect(find.byType(AddHabitSheet), findsOneWidget);

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('New Habit'), findsOneWidget);

      final saveHabitFinder = find.ancestor(
        of: find.text('Save Habit'),
        matching: find.byType(ElevatedButton),
      );

      final habitNameFinder = find.ancestor(
        of: find.text('Habit Name'),
        matching: find.byType(TextField),
      );

      expect(tester.widget<ElevatedButton>(saveHabitFinder).onPressed, isNull);

      await tester.enterText(habitNameFinder, '   ');
      await tester.pump();

      expect(tester.widget<ElevatedButton>(saveHabitFinder).onPressed, isNull);

      await tester.enterText(habitNameFinder, '  Walk  ');
      await tester.pump();

      expect(
        tester.widget<ElevatedButton>(saveHabitFinder).onPressed,
        isNotNull,
      );

      await tester.enterText(habitNameFinder, '');
      await tester.pump();

      expect(tester.widget<ElevatedButton>(saveHabitFinder).onPressed, isNull);

      await tester.enterText(habitNameFinder, 'Read');

      await tester.pumpAndSettle();

      expect(
        tester.widget<ElevatedButton>(saveHabitFinder).onPressed,
        isNotNull,
      );

      await tester.tap(find.byIcon(Icons.close));

      await tester.pumpAndSettle();

      expect(
        tester
            .widget<HabitCompletionIndicator>(walkIndicatorFinder)
            .isCompleted,
        isFalse,
      );

      expect(find.byType(AddHabitSheet), findsNothing);

      expect(find.text('2 of 4'), findsOneWidget);

      expect(find.text('50%'), findsOneWidget);

      expect(find.byType(HabitCard), findsNWidgets(4));
    },
    skip: true, //Pending persistent daily habit completion implementation
  );

  testWidgets('Add Habit Sheet', (WidgetTester tester) async {
    String? receivedName;
    String? receivedDescription;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddHabitSheet(
            onClose: () {},
            onSave: (name, description) async {
              receivedName = name;
              receivedDescription = description;
            },
          ),
        ),
      ),
    );

    final nameFieldFinder = find.byType(TextField).at(0);
    final descriptionFieldFinder = find.byType(TextField).at(1);
    final saveHabitFinder = find.ancestor(
      of: find.text('Save Habit'),
      matching: find.byType(ElevatedButton),
    );

    await tester.enterText(nameFieldFinder, '  Morning Walk  ');
    await tester.enterText(descriptionFieldFinder, '  Walk for 30 minutes  ');

    await tester.pumpAndSettle();

    await tester.tap(saveHabitFinder);

    await tester.pumpAndSettle();

    expect(find.byType(AddHabitSheet), findsOneWidget);

    expect(receivedName, 'Morning Walk');
    expect(receivedDescription, 'Walk for 30 minutes');
  });

  testWidgets('Test Adding a new Habit', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(habitRepository: repository)),
    );

    await tester.pumpAndSettle();

    expect(find.text('0 of 0'), findsOneWidget);

    expect(find.text('0%'), findsOneWidget);

    expect(find.byType(HabitCard), findsNothing);

    expect(find.text('No habits yet. Add your first habit!'), findsOneWidget);

    final addHabitButtonFinder = find.byType(AddHabitButton);

    await tester.tap(addHabitButtonFinder);

    await tester.pumpAndSettle();

    final nameFieldFinder = find.byType(TextField).at(0);
    final descriptionFieldFinder = find.byType(TextField).at(1);
    final saveHabitFinder = find.ancestor(
      of: find.text('Save Habit'),
      matching: find.byType(ElevatedButton),
    );

    await tester.enterText(nameFieldFinder, 'Morning Walk');
    await tester.enterText(descriptionFieldFinder, 'Walk for 30 minutes');

    await tester.pumpAndSettle();

    await tester.tap(saveHabitFinder);

    await tester.pumpAndSettle();

    expect(find.byType(AddHabitSheet), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Morning Walk'),
      150,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    expect(find.text('Morning Walk'), findsOneWidget);
    expect(find.text('Walk for 30 minutes'), findsOneWidget);

    expect(find.text('0 of 1'), findsOneWidget);

    expect(find.text('0%'), findsOneWidget);

    final newHabitCardFinder = find.ancestor(
      of: find.text('Morning Walk'),
      matching: find.byType(HabitCard),
    );

    final newHabitCardIndicatorFinder = find.descendant(
      of: newHabitCardFinder,
      matching: find.byType(HabitCompletionIndicator),
    );

    expect(
      tester
          .widget<HabitCompletionIndicator>(newHabitCardIndicatorFinder)
          .isCompleted,
      isFalse,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('displays habits loaded from the repository', (tester) async {
    final domain.Habit habit = domain.Habit(
      id: 'habit-1',
      title: 'Morning Walk',
      description: 'Walk for 30 minutes',
    );

    await repository.addHabit(habit);

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(habitRepository: repository)),
    );

    await tester.pumpAndSettle();

    final progressFinder = find.byType(LinearProgressIndicator);

    expect(find.text('0 of 1'), findsOneWidget);

    expect(find.text('0%'), findsOneWidget);

    expect(find.text('Morning Walk'), findsOneWidget);

    expect(find.text('Walk for 30 minutes'), findsOneWidget);

    expect(tester.widget<LinearProgressIndicator>(progressFinder).value, 0.0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
