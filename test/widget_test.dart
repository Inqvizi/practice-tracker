import 'package:flutter_test/flutter_test.dart';
import 'package:practice_tracker/app.dart';

void main() {
  testWidgets('PracticeTrackerApp smoke test: loads LoginScreen by default',
      (WidgetTester tester) async {
    // Build application and trigger frame
    await tester.pumpWidget(const PracticeTrackerApp());
    await tester.pumpAndSettle();

    // Verify key brand and login elements are present
    expect(find.text('Practice'), findsWidgets);
    expect(find.text('TRACKER'), findsWidgets);
    expect(find.text('Log in to Practice Tracker'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
