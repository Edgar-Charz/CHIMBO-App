import 'package:chimbo/features/auth/presentation/widgets/pin_pad.dart';
import 'package:flutter_test/flutter_test.dart';

/// Types [pin] on the app's number pad, one key at a time.
Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    final key = find.descendant(
      of: find.byType(PinPad),
      matching: find.text(digit),
    );
    await tester.ensureVisible(key);
    await tester.tap(key);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
