import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_timer/main.dart';

void main() {
  testWidgets('App loads and shows Focus Timer after onboarding', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});

    await tester.pumpWidget(const FocusTimerApp());
    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsWidgets);
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('Onboarding shows when not completed', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FocusTimerApp());
    await tester.pumpAndSettle();

    expect(find.text('Focus Timer'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
