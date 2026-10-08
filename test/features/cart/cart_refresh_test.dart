import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_customer_store.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('pulling Kikapu refreshes its latest server details', (
    tester,
  ) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);

    await tester.tap(find.text('Kikapu'));
    await tester.pumpAndSettle();
    expect(find.text('Kikapu Chako'), findsOneWidget);
    expect(
      find.text('Ongeza bidhaa uanze kuagiza kwa bei za jumla.'),
      findsOneWidget,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
    );
    await container.read(fakeCustomerStoreProvider).write('cart', {'101': 6});

    await tester.drag(find.byType(ListView).last, const Offset(0, 360));
    await tester.pumpAndSettle();

    expect(find.text('Vaseline Petroleum Jelly 400ml'), findsOneWidget);
    expect(find.text('6+ pcs @ TZS 5,000'), findsOneWidget);
  });
}
