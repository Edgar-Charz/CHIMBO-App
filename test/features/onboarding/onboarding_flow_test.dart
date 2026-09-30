import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('splash shows the tagline and the new slogan, then leaves', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pump(AppDurations.slow);

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(
      find.text(
        'BIDHAA BORA  •  BEI NAFUU  •  BIASHARA IMARA',
        findRichText: true,
      ),
      findsOneWidget,
    );
    // D-3: "Jaza stock" is replaced everywhere.
    expect(
      find.text('Agiza. Amini. Pokea. Kuza Biashara.', findRichText: true),
      findsOneWidget,
    );

    await tester.pump(SplashScreen.displayTime);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets(
    'first launch: 3 slides, Anza Sasa opens registration and remembers it',
    (tester) async {
      final preferences = await pumpAppPastSplash(tester);

      expect(find.text('Bidhaa za Biashara Yako'), findsOneWidget);
      expect(find.text('JEWELRY'), findsOneWidget);

      await tester.tap(find.text('Endelea'));
      await tester.pumpAndSettle();
      expect(find.text('Bei za Jumla Zinazokulipa'), findsOneWidget);
      expect(find.text('TZS 4,400'), findsOneWidget);

      await tester.tap(find.text('Endelea'));
      await tester.pumpAndSettle();
      expect(find.text('Agiza kwa Urahisi. Pokea Haraka.'), findsOneWidget);

      await tester.tap(find.text('Anza Sasa'));
      await tester.pumpAndSettle();

      // Logged out, so the router sends the customer to registration step 1.
      expect(find.text('Karibu CHIMBO'), findsOneWidget);
      expect(preferences.getBool('onboarding_seen'), isTrue);
    },
  );

  testWidgets('back on slide 2 returns to slide 1', (tester) async {
    await pumpAppPastSplash(tester);
    await tester.tap(find.text('Endelea'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Bidhaa za Biashara Yako'), findsOneWidget);
  });
}
