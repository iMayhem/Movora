import 'package:flutter_test/flutter_test.dart';
import 'package:movora/main.dart';

void main() {
  testWidgets('Movora app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MovoraApp());

    // Verify that the app title is displayed
    expect(find.text('Movora'), findsOneWidget);
  });
}
