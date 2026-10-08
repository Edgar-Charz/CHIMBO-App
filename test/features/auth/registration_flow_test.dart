import 'package:chimbo/core/widgets/otp_input.dart';
import 'package:chimbo/core/widgets/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pin_pad_helpers.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> enterPhone(WidgetTester tester, String phone) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(PhoneField),
        matching: find.byType(TextField),
      ),
      phone,
    );
    await tapButton(tester, 'Endelea');
  }

  testWidgets('a logged-out customer starts on step 1', (tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true);

    expect(find.text('Karibu CHIMBO'), findsOneWidget);
    expect(find.text('Hatua 1 kati ya 4'), findsOneWidget);
  });

  testWidgets('step 1 rejects a number that is not a Tanzanian mobile', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true);

    await enterPhone(tester, '512345678');

    expect(
      find.text('Weka namba sahihi ya simu, mfano 712 345 678.'),
      findsOneWidget,
    );
    expect(find.text('Thibitisha Namba'), findsNothing);
  });

  testWidgets('phone → any code → PIN → business info → Nyumbani', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true);

    // Step 1: a leading 0 is dropped and the digits are grouped.
    await enterPhone(tester, '0712345678');

    // Step 2.
    expect(find.text('Hatua 2 kati ya 4'), findsOneWidget);
    expect(find.text('+255 712 345 678'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(OtpInput),
        matching: find.byType(TextField),
      ),
      '482619',
    );
    await tester.pumpAndSettle();

    // Step 3: an easy PIN is refused by the server, then a good one is entered twice.
    expect(find.text('Tengeneza PIN'), findsOneWidget);
    expect(find.text('Hatua 3 kati ya 4'), findsOneWidget);
    await enterPin(tester, '1234');
    await tapButton(tester, 'Endelea');
    await enterPin(tester, '1234');
    await tapButton(tester, 'Hifadhi PIN');
    expect(find.text('Chagua PIN isiyo rahisi kukisia.'), findsOneWidget);
    expect(find.text('Chagua PIN ya tarakimu 4 hadi 6'), findsOneWidget);

    await enterPin(tester, '4826');
    await tapButton(tester, 'Endelea');
    // A different second PIN is caught before anything is sent.
    await enterPin(tester, '4827');
    await tapButton(tester, 'Hifadhi PIN');
    expect(find.text('PIN hazilingani. Rudia tena.'), findsOneWidget);
    await enterPin(tester, '4826');
    await tapButton(tester, 'Hifadhi PIN');

    // Step 4: name and region are required.
    expect(find.text('Hatua 4 kati ya 4'), findsOneWidget);
    await tapButton(tester, 'Ingia CHIMBO');
    expect(find.text('Andika jina lako kamili.'), findsOneWidget);
    expect(find.text('Chagua mkoa wako.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Jina kamili'),
      'Joyce Joseph',
    );
    await tester.ensureVisible(find.text('Chagua mkoa'));
    await tester.tap(find.text('Chagua mkoa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dar es Salaam').last);
    await tester.pumpAndSettle();
    await tapButton(tester, 'Ingia CHIMBO');

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('"Badilisha namba" goes back to step 1', (tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true);
    await enterPhone(tester, '712345678');

    await tapButton(tester, 'Badilisha namba');

    expect(find.text('Karibu CHIMBO'), findsOneWidget);
  });
}
