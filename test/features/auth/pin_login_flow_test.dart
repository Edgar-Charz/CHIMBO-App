import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/core/widgets/otp_input.dart';
import 'package:chimbo/core/widgets/phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pin_pad_helpers.dart';
import '../../helpers/pump_app.dart';

void main() {
  const wrongPinMessage = 'PIN si sahihi. Umebakiza majaribio 4.';

  Future<void> tapText(WidgetTester tester, String label) async {
    final button = find.text(label).last;
    await tester.dragUntilVisible(
      button,
      find.byType(Scrollable).last,
      const Offset(0, -300),
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> submitPhone(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(PhoneField),
        matching: find.byType(TextField),
      ),
      '712345678',
    );
    await tapText(tester, 'Endelea');
  }

  /// A registered customer (PIN [testPin]) types their number on the phone screen.
  Future<void> openPinScreen(WidgetTester tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, hasAccount: true);
    await submitPhone(tester);
    expect(find.text('Ingia kwa PIN'), findsOneWidget);
  }

  Future<void> enterWrongPinFiveTimes(WidgetTester tester) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      await enterPin(tester, '1111');
      await tapText(tester, 'Ingia');
    }
  }

  Future<void> enterCode(WidgetTester tester) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(OtpInput),
        matching: find.byType(TextField),
      ),
      '482619',
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a wrong PIN says how many tries are left; the right one logs in',
    (tester) async {
      await openPinScreen(tester);

      await enterPin(tester, '1111');
      await tapText(tester, 'Ingia');
      expect(find.text(wrongPinMessage), findsOneWidget);

      await enterPin(tester, testPin);
      await tapText(tester, 'Ingia');
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets('Umesahau PIN?: SMS code, new PIN, then Nyumbani', (
    tester,
  ) async {
    await openPinScreen(tester);

    await tapText(tester, 'Umesahau PIN?');
    expect(find.text('Thibitisha Namba'), findsOneWidget);
    // Not registration: no step dots.
    expect(find.textContaining('Hatua'), findsNothing);
    await enterCode(tester);

    // Logged in by SMS, but a new PIN is still asked before Home.
    expect(find.text('Weka PIN Mpya'), findsOneWidget);
    await enterPin(tester, '2580');
    await tapText(tester, 'Endelea');
    await enterPin(tester, '2580');
    await tapText(tester, 'Hifadhi PIN');

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('the 5th wrong PIN locks it and starts "Umesahau PIN?"', (
    tester,
  ) async {
    await openPinScreen(tester);

    await enterWrongPinFiveTimes(tester);

    expect(find.text('Thibitisha Namba'), findsOneWidget);
  });

  testWidgets('a locked PIN shows only "Umesahau PIN?" next time', (
    tester,
  ) async {
    await openPinScreen(tester);
    await enterWrongPinFiveTimes(tester);
    // Back from the code screen, then from the PIN screen, to the phone screen.
    await tapText(tester, 'Badilisha namba');
    await tester.ensureVisible(find.byTooltip('Rudi'));
    await tester.tap(find.byTooltip('Rudi'));
    await tester.pumpAndSettle();

    await tapText(tester, 'Endelea');

    expect(find.textContaining('PIN imefungwa'), findsOneWidget);
    expect(find.text('Ingia'), findsNothing);
  });

  testWidgets('Badilisha PIN in Wasifu checks the current PIN first', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);
    await tester.tap(find.text('Wasifu'));
    await tester.pumpAndSettle();
    final profileList = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Badilisha PIN'),
      profileList,
      const Offset(0, -300),
    );
    await tester.drag(profileList, const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Badilisha PIN'));
    await tester.pumpAndSettle();

    Future<void> changePin(String current) async {
      await enterPin(tester, current);
      await tapText(tester, 'Endelea');
      await enterPin(tester, '2580');
      await tapText(tester, 'Endelea');
      await enterPin(tester, '2580');
      final saveButton = find.widgetWithText(FilledButton, 'Badilisha PIN');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
    }

    await changePin('9999');
    // Back on the first step with the server's message.
    expect(find.text(wrongPinMessage), findsOneWidget);
    expect(find.text('Weka PIN yako ya sasa'), findsOneWidget);

    await changePin(testPin);
    expect(find.text('PIN imebadilishwa.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('a refused login token anywhere returns to the phone screen', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);

    // What the 401 handler reports when the server refuses the token.
    ProviderScope.containerOf(tester.element(find.byType(NavigationBar)))
        .read(sessionExpiredEventsProvider)
        .add(null);
    await tester.pumpAndSettle();

    expect(find.text('Karibu CHIMBO'), findsOneWidget);
    expect(
      find.text('Umetolewa kwenye akaunti. Tafadhali ingia tena.'),
      findsOneWidget,
    );
  });

  testWidgets('the PIN screen fits a phone without scrolling', (tester) async {
    await openPinScreen(tester);

    // 360 × 800 (pumpApp's phone size): the picture shrinks, nothing scrolls.
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scroll.position.maxScrollExtent, 0);
    expect(find.text('Umesahau PIN?').hitTestable(), findsOneWidget);
  });

  testWidgets('on a very small screen it scrolls instead of overflowing', (
    tester,
  ) async {
    await openPinScreen(tester);
    tester.view.physicalSize = const Size(1080, 1500);
    await tester.pumpAndSettle();

    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
