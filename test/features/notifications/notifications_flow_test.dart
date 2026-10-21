import 'package:chimbo/features/notifications/data/models/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_notifications_repository.dart';
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

  testWidgets(
    'tapping an order notification for a missing order shows fallback error',
    (tester) async {
      final fakeNotifs = FakeNotificationsRepository([
        AppNotification(
          id: 99,
          type: NotificationType.orderStatus,
          title: 'Oda ya ajabu',
          body: 'Oda isiyokuwepo.',
          isRead: false,
          createdAt: DateTime(2026, 9, 30, 9),
          orderId: 99999,
        ),
      ]);

      await pumpAppPastSplash(
        tester,
        hasSeenOnboarding: true,
        isLoggedIn: true,
        notificationsRepository: fakeNotifs,
      );

      await tester.tap(find.byTooltip('Arifa'));
      await tester.pumpAndSettle();
      expect(find.text('Oda ya ajabu'), findsOneWidget);

      await tester.tap(find.text('Oda ya ajabu'));
      await tester.pumpAndSettle();

      // Fallback error is shown with "Oda haijapatikana"
      expect(find.text('Oda haijapatikana'), findsOneWidget);
      expect(
        find.text('Oda hii haipo au huenda imeondolewa.'),
        findsOneWidget,
      );
      expect(find.text('Ona oda zangu'), findsOneWidget);

      // Tapping "Ona oda zangu" navigates to orders list safely
      await tester.tap(find.text('Ona oda zangu'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Oda Zangu'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a promo notification with productId opens product details',
    (tester) async {
      final fakeNotifs = FakeNotificationsRepository([
        AppNotification(
          id: 50,
          type: NotificationType.promo,
          title: 'Ofa Maalum ya Vaseline',
          body: 'Pata punguzo la 20% sasa.',
          isRead: false,
          createdAt: DateTime(2026, 9, 30, 9),
          productId: 101,
        ),
      ]);

      await pumpAppPastSplash(
        tester,
        hasSeenOnboarding: true,
        isLoggedIn: true,
        notificationsRepository: fakeNotifs,
      );

      await tester.tap(find.byTooltip('Arifa'));
      await tester.pumpAndSettle();
      expect(find.text('Ofa Maalum ya Vaseline'), findsOneWidget);

      await tester.tap(find.text('Ofa Maalum ya Vaseline'));
      await tester.pumpAndSettle();

      expect(find.text('Vaseline Petroleum Jelly 400ml'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a wishlist notification without productId opens Vipendwa page',
    (tester) async {
      final fakeNotifs = FakeNotificationsRepository([
        AppNotification(
          id: 52,
          type: NotificationType.promo,
          title: 'Vipendwa Vyako Vina Punguzo!',
          body: 'Bidhaa ulizozihifadhi kwenye Vipendwa zina ofa leo.',
          isRead: false,
          createdAt: DateTime(2026, 9, 30, 9),
          target: 'wishlist',
        ),
      ]);

      await pumpAppPastSplash(
        tester,
        hasSeenOnboarding: true,
        isLoggedIn: true,
        notificationsRepository: fakeNotifs,
      );

      await tester.tap(find.byTooltip('Arifa'));
      await tester.pumpAndSettle();
      expect(find.text('Vipendwa Vyako Vina Punguzo!'), findsOneWidget);

      await tester.tap(find.text('Vipendwa Vyako Vina Punguzo!'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Vipendwa'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping a notification with productId pushes product details and back returns to Arifa',
    (tester) async {
      final fakeNotifs = FakeNotificationsRepository([
        AppNotification(
          id: 53,
          type: NotificationType.promo,
          title: 'Bidhaa ya Vipendwa Ina Punguzo! 🔥',
          body:
              'Vaseline Petroleum Jelly 400ml uliyoiweka kwenye Vipendwa sasa ina punguzo la 10%!',
          isRead: false,
          createdAt: DateTime(2026, 9, 30, 9),
          productId: 101,
        ),
      ]);

      await pumpAppPastSplash(
        tester,
        hasSeenOnboarding: true,
        isLoggedIn: true,
        notificationsRepository: fakeNotifs,
      );

      await tester.tap(find.byTooltip('Arifa'));
      await tester.pumpAndSettle();
      expect(find.text('Bidhaa ya Vipendwa Ina Punguzo! 🔥'), findsOneWidget);

      await tester.tap(find.text('Bidhaa ya Vipendwa Ina Punguzo! 🔥'));
      await tester.pumpAndSettle();

      // Product details screen is open
      expect(find.text('Vaseline Petroleum Jelly 400ml'), findsOneWidget);

      // Tapping back returns to the Arifa notifications list
      await goBack(tester);
      expect(find.widgetWithText(AppBar, 'Arifa'), findsOneWidget);
    },
  );
}
