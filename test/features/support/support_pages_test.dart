import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> openWasifuItem(WidgetTester tester, String title) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);
    await tester.tap(find.text('Wasifu'));
    await tester.pumpAndSettle();
    final menu = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text(title),
      menu,
      const Offset(0, -300),
    );
    // Further up, so the row isn't hidden behind the bottom bar.
    await tester.drag(menu, const Offset(0, -250));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  testWidgets('Msaada shows the hours, a call and a WhatsApp button', (
    tester,
  ) async {
    await openWasifuItem(tester, 'Msaada');

    expect(
      find.text('Jumatatu–Jumamosi, saa 2 asubuhi – saa 12 jioni'),
      findsOneWidget,
    );
    expect(find.text('Piga simu +255 700 111 222'), findsOneWidget);
    expect(find.text('Tuma ujumbe WhatsApp'), findsOneWidget);
  });

  testWidgets('Msaada lists the common questions; a tap shows the answer', (
    tester,
  ) async {
    await openWasifuItem(tester, 'Msaada');
    final question = find.text('Usafiri unalipwaje?');
    await tester.dragUntilVisible(
      question,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );

    await tester.tap(question);
    await tester.pumpAndSettle();

    expect(
      find.text('Dar es Salaam unamlipa dereva moja kwa moja ukipokea.'),
      findsOneWidget,
    );
  });

  testWidgets('Vigezo na Masharti shows each paragraph', (tester) async {
    await openWasifuItem(tester, 'Vigezo na Masharti');

    expect(find.widgetWithText(AppBar, 'Vigezo na Masharti'), findsOneWidget);
    expect(find.text('Aya ya kwanza.'), findsOneWidget);
    expect(find.text('Aya ya pili.'), findsOneWidget);
  });

  testWidgets('the login screen links open the pages while logged out', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true);

    // "Sera ya Faragha" is the second link in the sentence under the button.
    await tester.tapOnText(find.textRange.ofSubstring('Sera ya Faragha'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Sera ya Faragha'), findsOneWidget);
    expect(find.text('Aya ya kwanza.'), findsOneWidget);
  });
}
