import 'package:chimbo/features/home/presentation/widgets/greeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets(
    'logged-in customer lands on Nyumbani with the 5 Kiswahili tabs and switches tabs',
    (tester) async {
      await pumpAppPastSplash(
        tester,
        hasSeenOnboarding: true,
        isLoggedIn: true,
      );

      for (final label in ['Nyumbani', 'Gundua', 'Kikapu', 'Oda', 'Wasifu']) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      // Home has no app bar; its greeting card shows instead.
      expect(find.byType(GreetingCard), findsOneWidget);

      await tester.tap(find.text('Oda'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Oda Zangu'), findsOneWidget);
    },
  );
}
