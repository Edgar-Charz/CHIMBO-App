import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Finder bellCount(String count) =>
      find.descendant(of: find.byTooltip('Arifa'), matching: find.text(count));

  // `tester.pageBack()` looks for the English "Back" tooltip; the app is in Kiswahili.
  Future<void> goBack(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  Future<void> openNotifications(WidgetTester tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);
    expect(bellCount('2'), findsOneWidget);
    await tester.tap(find.byTooltip('Arifa'));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping an order notification reads it and opens the order', (
    tester,
  ) async {
    await openNotifications(tester);
    expect(find.text('Oda imetumwa'), findsOneWidget);

    await tester.tap(find.text('Oda imetumwa'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Fuatilia Oda'), findsOneWidget);

    // Back on Nyumbani (still on Arifa), one notification is left unread.
    await tester.tap(find.text('Nyumbani'));
    await tester.pumpAndSettle();
    await goBack(tester);
    expect(bellCount('1'), findsOneWidget);
  });

  testWidgets('Soma zote reads everything and clears the bell', (tester) async {
    await openNotifications(tester);

    await tester.tap(find.text('Soma zote'));
    await tester.pumpAndSettle();
    expect(find.text('Soma zote'), findsNothing);

    await goBack(tester);
    expect(bellCount('2'), findsNothing);
    expect(bellCount('1'), findsNothing);
  });
}
