// This is a basic Flutter widget test for Focus Timer app.

import 'package:flutter_test/flutter_test.dart';

import 'package:focus_timer/main.dart';

void main() {
  testWidgets('App loads and shows Focus Timer', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusTimerApp());
    await tester.pumpAndSettle();

    expect(find.text('Focus Timer'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
  });
}
