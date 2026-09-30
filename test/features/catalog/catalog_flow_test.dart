import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';
import '../../helpers/gestures.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<void> openHome(WidgetTester tester) async {
    await pumpAppPastSplash(tester, hasSeenOnboarding: true, isLoggedIn: true);
  }

  testWidgets('Home greets the customer and shows both categories', (
    tester,
  ) async {
    await openHome(tester);

    expect(find.textContaining('Joyce!'), findsOneWidget);
    expect(find.text('COSMETICS'), findsOneWidget);
    expect(find.text('Shamba la Vipodozi'), findsOneWidget);
    expect(find.text('JEWELRY'), findsOneWidget);
  });

  testWidgets('Cosmetics → a chip narrows the grid to that sub-category', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Angalia').first);
    await tester.pumpAndSettle();

    expect(find.text('Tafuta kwenye Cosmetics...'), findsOneWidget);
    expect(find.text('Vaseline Petroleum Jelly 400ml'), findsOneWidget);

    // Chips scroll sideways: bring it into view first.
    await tester.ensureVisible(find.text('Hair Care'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hair Care'));
    await tester.pumpAndSettle();

    // The category page shows rails above the full grid, so a product can appear twice.
    expect(find.text('Hair Food 500ml (Dark & Lovely)'), findsWidgets);
    expect(find.text('Vaseline Petroleum Jelly 400ml'), findsNothing);
  });

  testWidgets('product page: tiers, stepper and live savings', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Angalia').first);
    await tester.pumpAndSettle();
    await tapText(tester, 'Vaseline Petroleum Jelly 400ml');

    expect(find.text('Nunua zaidi, lipa kidogo'), findsOneWidget);
    expect(find.text('60+ pcs'), findsOneWidget);

    // From the MOQ (1) up to 8 pieces: the 6–23 tier, saving (5,500 − 5,000) × 8.
    final increase = find.byTooltip('Ongeza');
    await tester.ensureVisible(increase);
    await tester.pumpAndSettle();
    for (var tap = 0; tap < 7; tap++) {
      await tester.tap(increase);
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Unaokoa TZS 4,000'), findsOneWidget);
    expect(
      find.text('Ongeza pcs 16 upate TZS 4,700 kila moja'),
      findsOneWidget,
    );
  });

  testWidgets('a search with no match shows the empty state', (tester) async {
    await openHome(tester);
    await tapText(tester, 'Gundua');

    await tester.enterText(find.byType(TextField).first, 'hakuna kitu');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byType(ProductCard), findsNothing);
    expect(find.text('Hakuna bidhaa'), findsOneWidget);
  });

  testWidgets('deal cards show the discount and old price; the heart saves', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Ofa'));
    await tester.pumpAndSettle();

    // Matte Lipstick Set: 7,500 instead of 9,000 → -17%; no "kuanzia" line on cards.
    expect(find.text('-17%'), findsOneWidget);
    expect(find.text('TZS 9,000'), findsOneWidget);
    expect(find.textContaining('kuanzia'), findsNothing);

    await tester.tap(find.byTooltip('Penda').first);
    await tester.pumpAndSettle();
    expect(find.text('Imehifadhiwa kwenye vipendwa.'), findsOneWidget);
    expect(find.byTooltip('Ondoa kwenye vipendwa'), findsOneWidget);
  });

  testWidgets('a sold-out product says Imeisha and cannot be added', (
    tester,
  ) async {
    await openHome(tester);
    await tester.tap(find.text('Angalia').first);
    await tester.pumpAndSettle();
    // Chips scroll sideways: bring it into view first.
    await tester.ensureVisible(find.text('Body Care'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Body Care'));
    await tester.pumpAndSettle();

    // The sold-out card: scroll to it, then check its label.
    final soldOut = find.text('Imeisha');
    await tester.dragUntilVisible(
      soldOut,
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(soldOut, findsOneWidget);

    await tapText(tester, 'Nourish Body Oil 100ml');
    expect(find.text('Imeisha stock'), findsOneWidget);
    final addButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Imeisha stock'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(addButton.onPressed, isNull);
  });

  test('dev catalog lists sold-out products last', () async {
    final bodyCare = await const FakeCatalogRepository().getProducts(
      const ProductQuery(categoryId: 13),
      page: 1,
    );
    expect(bodyCare.items.last.name, 'Nourish Body Oil 100ml');
    expect(bodyCare.items.last.isInStock, isFalse);
    expect(bodyCare.items.first.isInStock, isTrue);
  });

  test('dev catalog filters by collection, price band and MOQ', () async {
    const repository = FakeCatalogRepository();

    final deals = await repository.getProducts(
      const ProductQuery(collection: ProductCollection.deals),
      page: 1,
    );
    expect(deals.items, isNotEmpty);
    expect(deals.items.every((item) => item.badge?.apiValue == 'deal'), isTrue);

    final cheapSingles = await repository.getProducts(
      const ProductQuery(
        priceBand: PriceBand.under5000,
        moqBand: MoqBand.single,
        sort: ProductSort.priceLowToHigh,
      ),
      page: 1,
    );
    final prices = cheapSingles.items.map((item) => item.price).toList();
    expect(prices.every((price) => price < 5000), isTrue);
    expect(cheapSingles.items.every((item) => item.moq == 1), isTrue);
    expect(prices, orderedEquals([...prices]..sort()));
  });
}
