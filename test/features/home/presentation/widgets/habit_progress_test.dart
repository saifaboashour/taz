import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taz/features/home/presentation/widgets/habit_progress.dart';

void main() {
  group('HabitProgress Widget Tests', () {
    testWidgets('1. No habits (0/0) shows 0.0 progress and 0%', (tester) async {
      // Pump widget inside MaterialApp and Scaffold
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HabitProgress(completedCount: 0, totalCount: 0)),
        ),
      );

      // Verify count label
      expect(find.text('0 of 0'), findsOneWidget);

      // Verify displayed percentage text
      expect(find.text('0%'), findsOneWidget);

      // Verify LinearProgressIndicator.value
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.0);
    });

    testWidgets('2. Partial completion (2/4) shows 0.5 progress and 50%', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HabitProgress(completedCount: 2, totalCount: 4)),
        ),
      );

      // Verify count label
      expect(find.text('2 of 4'), findsOneWidget);

      // Verify displayed percentage text
      expect(find.text('50%'), findsOneWidget);

      // Verify LinearProgressIndicator.value
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('3. All completed (4/4) shows 1.0 progress and 100%', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HabitProgress(completedCount: 4, totalCount: 4)),
        ),
      );

      // Verify count label
      expect(find.text('4 of 4'), findsOneWidget);

      // Verify displayed percentage text
      expect(find.text('100%'), findsOneWidget);

      // Verify LinearProgressIndicator.value
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 1.0);
    });

    testWidgets(
      '4. Completed exceeds total (5/4) clamps progress to 1.0 and shows 100%',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HabitProgress(completedCount: 5, totalCount: 4),
            ),
          ),
        );

        // Verify count label
        expect(find.text('5 of 4'), findsOneWidget);

        // Verify displayed percentage text
        expect(find.text('100%'), findsOneWidget);

        // Verify LinearProgressIndicator.value is clamped to 1.0
        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 1.0);
      },
    );
  });
}
