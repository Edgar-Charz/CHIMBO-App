import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/catalog/data/models/product_photo.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_gallery.dart';
import 'package:chimbo/features/wishlist/application/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('product card gives a brief press response', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartControllerProvider.overrideWith(_EmptyCartController.new),
          wishlistControllerProvider.overrideWith(_EmptyWishlistController.new),
        ],
        child: MaterialApp(
          locale: const Locale('sw'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: const Scaffold(
            body: ProductCard(
              product: ProductSummary(
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
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final imageTapTarget = find.byType(InkWell).first;
    final gesture = await tester.startGesture(tester.getCenter(imageTapTarget));
    await tester.pump();

    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      lessThan(1),
    );

    await gesture.cancel();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product gallery indicates the current photo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SizedBox(
            width: 360,
            child: ProductGallery(
              heroTag: 'test-product-image',
              photos: [
                ProductPhoto.singleSize('https://example.test/one.webp'),
                ProductPhoto.singleSize('https://example.test/two.webp'),
                ProductPhoto.singleSize('https://example.test/three.webp'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 / 3'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-240, 0));
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _EmptyCartController extends CartController {
  @override
  Future<Cart> build() async => Cart.empty;
}

class _EmptyWishlistController extends WishlistController {
  @override
  Future<Set<int>> build() async => const {};
}
