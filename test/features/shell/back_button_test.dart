import 'package:chimbo/features/home/presentation/widgets/greeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  const exitHint = 'Bonyeza nyuma tena ili kutoka.';

  // Android's back button / back swipe.
  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  Future<void> openHome(WidgetTester tester) =>
      pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);

  testWidgets('one back on Nyumbani asks first instead of closing the app', (
    tester,
  ) async {
    await openHome(tester);

    await pressBack(tester);

    expect(find.text(exitHint), findsOneWidget);
    expect(find.byTooltip('Arifa'), findsOneWidget);
  });

  testWidgets('back on another tab goes to Nyumbani first', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Oda'));
    await tester.pumpAndSettle();

    await pressBack(tester);

    expect(find.byTooltip('Arifa'), findsOneWidget);
    expect(find.text(exitHint), findsNothing);
  });

  testWidgets('back inside a tab closes that screen as usual', (tester) async {
    await openHome(tester);
    await tester.tap(find.byTooltip('Arifa'));
    await tester.pumpAndSettle();
    expect(find.text('Soma zote'), findsOneWidget);

    await pressBack(tester);

    expect(find.text('Soma zote'), findsNothing);
    expect(find.byTooltip('Arifa'), findsOneWidget);
    expect(find.text(exitHint), findsNothing);
  });

  testWidgets('back from a Home category returns to Nyumbani', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Angalia').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Cosmetics'), findsOneWidget);

    await pressBack(tester);

    expect(find.byType(GreetingCard), findsOneWidget);
    expect(find.text(exitHint), findsNothing);
  });

  testWidgets('the phone screen also asks before closing', (tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true);

    await pressBack(tester);

    expect(find.text(exitHint), findsOneWidget);
  });
}
