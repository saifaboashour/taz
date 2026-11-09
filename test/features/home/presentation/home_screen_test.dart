import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taz/features/home/presentation/home_screen.dart';
import 'package:taz/features/home/presentation/widgets/habit_card.dart';
import 'package:taz/features/home/presentation/widgets/habit_completion_indicator.dart';

void main() {
  testWidgets(
    'Verify that tapping a habit\'s completion indicator updates its state correctly without changing other habits.',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

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

      await tester.tap(walkIndicatorFinder);

      await tester.pump();

      expect(
        tester
            .widget<HabitCompletionIndicator>(walkIndicatorFinder)
            .isCompleted,
        isFalse,
      );

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
    },
  );
}
