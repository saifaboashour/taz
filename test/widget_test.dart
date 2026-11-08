import 'package:flutter_test/flutter_test.dart';
import 'package:taz/main.dart';

void main() {
  testWidgets('Home screen displays app title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Taz());

    // Verify that TAZ appears
    expect(find.text('TAZ'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
