import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/gestures.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'product → Kikapu → new address → Hakiki → order → tracking → cancel',
    (tester) async {
      await pumpAppPastSplash(
        tester,
        hasSeenOnboarding: true,
        isLoggedIn: true,
      );

      // Product page: 8 Vaseline into the cart.
      await tester.tap(find.text('Angalia').first);
      await tester.pumpAndSettle();
      await tapText(tester, 'Vaseline Petroleum Jelly 400ml');
      final increase = find.byTooltip('Ongeza');
      await tester.ensureVisible(increase);
      await tester.pumpAndSettle();
      for (var tap = 0; tap < 7; tap++) {
        await tester.tap(increase);
        await tester.pump();
      }
      await tester.tap(find.text('Ongeza Kikapuni'));
      await tester.pumpAndSettle();
      expect(find.text('Imeongezwa kikapuni.'), findsOneWidget);

      // Kikapu: priced by tier.
      await tester.tap(find.text('Ona Kikapu'));
      await tester.pumpAndSettle();
      expect(find.text('Kikapu Chako'), findsOneWidget);
      expect(find.text('6+ pcs @ TZS 5,000'), findsOneWidget);
      await tapText(tester, 'Endelea kwenye Malipo');

      // Checkout: no address yet → add one (name and phone come from the profile).
      expect(find.text('Malipo na Usafirishaji'), findsOneWidget);
      await tapText(tester, 'Ongeza anwani');
      await tester.enterText(
        find.widgetWithText(AppTextField, 'Mtaa / eneo'),
        'Kariakoo, Mtaa wa Lumumba',
      );
      await tapText(tester, 'Hifadhi anwani');
      expect(find.text('Kariakoo, Mtaa wa Lumumba, Arusha'), findsOneWidget);

      // 40,000 + Standard 5,000.
      expect(find.text('TZS 45,000'), findsOneWidget);
      await tapText(tester, 'Endelea Kuhakiki');
      expect(find.text('Hakiki Oda'), findsOneWidget);
      await tapText(tester, 'Thibitisha Oda');

      expect(find.text('Oda Imepokelewa!'), findsOneWidget);
      await tapText(tester, 'Fuatilia Oda');

      // Just placed: confirmed, so it can still be cancelled.
      expect(find.text('Tunaandaa oda yako.'), findsOneWidget);
      await tapText(tester, 'Ghairi oda');
      await tester.tap(find.widgetWithText(TextButton, 'Ghairi oda'));
      await tester.pumpAndSettle();
      // Cancelled: confirmed by a message, and it can't be cancelled again.
      expect(find.text('Oda imeghairiwa.'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Ghairi oda'), findsNothing);
    },
  );

  testWidgets('Oda Zangu: sample history sits under Zimefika with Agiza Tena', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);
    await tester.tap(find.text('Oda'));
    await tester.pumpAndSettle();

    expect(find.text('Oda Zangu'), findsOneWidget);
    await tester.tap(find.text('Zimefika'));
    await tester.pumpAndSettle();

    expect(find.text('Imewasili'), findsWidgets);
    await tapText(tester, 'Agiza Tena');

    // Back in the cart with the order's items.
    expect(find.text('Kikapu Chako'), findsOneWidget);
    expect(find.text('Bidhaa zimerudishwa kikapuni.'), findsOneWidget);
  });
}
