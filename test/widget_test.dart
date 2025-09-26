import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movora/main.dart';

void main() {
  testWidgets('Movora app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MovoraApp());
    await tester.pumpAndSettle();

    // Verify that the Hollywood title is displayed (main screen title)
    expect(find.text('Hollywood'), findsAtLeastNWidgets(1));

    // Open the drawer to check for Movora branding
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Verify that the Movora title is displayed in the drawer
    expect(find.text('MOVORA'), findsOneWidget);
  });
}
