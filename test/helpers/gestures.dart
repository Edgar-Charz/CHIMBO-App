import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Taps the first widget showing [text]. Lists build rows lazily, so it first scrolls the
/// screen's first scrollable until the text exists, then makes sure it is on screen.
Future<void> tapText(WidgetTester tester, String text) async {
  const maxScrolls = 15;
  final target = find.text(text);
  for (
    var scroll = 0;
    scroll < maxScrolls && target.evaluate().isEmpty;
    scroll++
  ) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
  await tester.tap(target.first);
  await tester.pumpAndSettle();
}
