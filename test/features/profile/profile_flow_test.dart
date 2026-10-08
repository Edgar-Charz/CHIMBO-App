import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:chimbo/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/gestures.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<void> openWasifu(WidgetTester tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);
    await tester.tap(find.text('Wasifu'));
    await tester.pumpAndSettle();
  }

  testWidgets('Wasifu shows the registered customer and the menu', (
    tester,
  ) async {
    await openWasifu(tester);

    expect(find.text('Joyce Joseph'), findsOneWidget);
    expect(find.text('JJ'), findsOneWidget);
    expect(find.text('+255 712 345 678'), findsOneWidget);
    expect(find.text('Arusha'), findsOneWidget);
    expect(find.text('Taarifa za Biashara'), findsOneWidget);
  });

  testWidgets('Hariri Wasifu saves a new name and shop', (tester) async {
    await openWasifu(tester);

    await tapText(tester, 'Hariri Wasifu');
    await tester.enterText(
      find.widgetWithText(AppTextField, 'Jina kamili'),
      'Asha Mussa',
    );
    await tester.enterText(
      find.widgetWithText(AppTextField, 'Jina la biashara / duka'),
      'Asha Cosmetics',
    );
    await tapText(tester, 'Hifadhi');
    // Back on Wasifu, which is still scrolled to the button: scroll up to the card.
    await tester.dragUntilVisible(
      find.text('Asha Mussa'),
      find.byType(Scrollable).first,
      const Offset(0, 300),
    );

    expect(find.text('Asha Mussa'), findsOneWidget);
    expect(find.text('AM'), findsOneWidget);
    expect(find.text('Asha Cosmetics'), findsOneWidget);
  });

  testWidgets('logout asks first, then returns to step 1', (tester) async {
    await openWasifu(tester);

    await tapText(tester, 'Toka kwenye Akaunti');
    await tester.tap(find.text('Ghairi'));
    await tester.pumpAndSettle();
    // Cancelled: still logged in on Wasifu.
    expect(find.text('Toka kwenye Akaunti'), findsOneWidget);
    expect(find.text('Karibu CHIMBO'), findsNothing);

    await tapText(tester, 'Toka kwenye Akaunti');
    await tester.tap(find.widgetWithText(TextButton, 'Toka'));
    await tester.pumpAndSettle();
    expect(find.text('Karibu CHIMBO'), findsOneWidget);
  });

  testWidgets('deleting the account returns to step 1 as a new customer', (
    tester,
  ) async {
    await openWasifu(tester);
    await tapText(tester, 'Mipangilio');
    expect(find.text('Kiswahili'), findsOneWidget);

    await tapText(tester, 'Futa akaunti');
    await tester.tap(find.widgetWithText(TextButton, 'Futa'));
    await tester.pumpAndSettle();

    expect(find.text('Karibu CHIMBO'), findsOneWidget);
  });

  testWidgets('Vipendwa: empty at first, then lists a liked product', (
    tester,
  ) async {
    await openWasifu(tester);
    await tapText(tester, 'Vipendwa');
    expect(find.text('Hakuna vipendwa bado'), findsOneWidget);

    // Like a product on Home, then come back.
    await tester.tap(find.text('Nyumbani'));
    await tester.pumpAndSettle();
    final heart = find.byTooltip('Penda').first;
    await tester.ensureVisible(heart);
    await tester.pumpAndSettle();
    await tester.tap(heart);
    await tester.pumpAndSettle();
    expect(find.text('Imehifadhiwa kwenye vipendwa.'), findsOneWidget);
    await tester.tap(find.text('Wasifu'));
    await tester.pumpAndSettle();

    expect(find.text('Hakuna vipendwa bado'), findsNothing);
    expect(find.byTooltip('Ondoa kwenye vipendwa'), findsOneWidget);

    // Unliking here removes it from the list at once.
    await tester.tap(find.byTooltip('Ondoa kwenye vipendwa'));
    await tester.pumpAndSettle();
    expect(find.text('Hakuna vipendwa bado'), findsOneWidget);
  });

  testWidgets('Arifa opens the notifications list', (tester) async {
    await openWasifu(tester);
    await tapText(tester, 'Taarifa za oda na malipo');

    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('Anwani za Usafirishaji opens the address list', (tester) async {
    await openWasifu(tester);
    await tapText(tester, 'Anwani za Usafirishaji');

    expect(find.text('Hakuna anwani bado'), findsOneWidget);
    expect(find.text('Ongeza anwani'), findsOneWidget);
  });

  testWidgets(
    'Malipo yangu: history in one tab, accepted methods in the other',
    (tester) async {
      await openWasifu(tester);
      await tapText(tester, 'Malipo yangu');

      expect(find.text('Imethibitishwa'), findsOneWidget);
      expect(find.text('Imekataliwa'), findsOneWidget);
      expect(find.text('Hatukupata malipo haya.'), findsOneWidget);
      expect(find.text('Namba ya muamala: QJK3X7ABC1'), findsOneWidget);
      expect(find.text('123456'), findsNothing);

      await tester.tap(find.text('Njia za malipo'));
      await tester.pumpAndSettle();

      expect(find.text('Njia za malipo tunazokubali'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
      expect(
        find.text('Lipa kwa pesa taslimu unapopokea mzigo.'),
        findsOneWidget,
      );
    },
  );
}
