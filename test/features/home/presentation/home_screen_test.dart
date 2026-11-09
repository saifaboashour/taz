import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taz/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:taz/features/home/presentation/home_screen.dart';
import 'package:taz/features/home/presentation/widgets/add_habit_button.dart';
import 'package:taz/features/home/presentation/widgets/habit_card.dart';
import 'package:taz/features/home/presentation/widgets/habit_completion_indicator.dart';

void main() {
  testWidgets(
    'Verify that tapping a habit\'s completion indicator updates its state correctly without changing other habits.',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

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
  );
}
