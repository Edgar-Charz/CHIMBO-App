import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/cart/presentation/widgets/cart_line_tile.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cart line total updates with a short transition', (
    tester,
  ) async {
    var lineTotal = 5000;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                CartLineTile(
                  line: _line(lineTotal),
                  isEditing: false,
                  onQuantityChanged: (_) {},
                  onRemove: () {},
                ),
                TextButton(
                  key: const ValueKey('change-total'),
                  onPressed: () => setState(() => lineTotal = 10000),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('change-total')));
    await tester.pump();

    expect(find.byKey(const ValueKey(10000)), findsOneWidget);
    final priceTransition = tester.widget<AnimatedSwitcher>(
      find.ancestor(
        of: find.byKey(const ValueKey(10000)),
        matching: find.byType(AnimatedSwitcher),
      ),
    );
    expect(priceTransition.duration, AppDurations.cartPrice);
    expect(priceTransition.duration.inMilliseconds, lessThanOrEqualTo(120));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

CartLine _line(int total) => CartLine(
  product: const ProductSummary(
    id: 1,
    name: 'Lipstick',
    slug: 'lipstick',
    categoryId: 1,
    price: 5000,
    priceFrom: 4500,
    moq: 1,
    sellerName: 'CHIMBO',
    isSellerVerified: true,
    isInStock: true,
  ),
  quantity: total ~/ 5000,
  unitPrice: 5000,
  tierMinQuantity: 1,
  lineTotal: total,
);
