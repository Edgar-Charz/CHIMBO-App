import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/checkout/presentation/checkout_screen.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('checkout delivery selection responds and stays selected', (
    tester,
  ) async {
    var isSelected = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ChoiceTile(
              title: 'Usafirishaji',
              isSelected: isSelected,
              onTap: () => setState(() => isSelected = !isSelected),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Usafirishaji'));
    await tester.pump();

    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('checkout step progress updates without layout errors', (
    tester,
  ) async {
    var currentStep = 1;

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
                CheckoutStepper(currentStep: currentStep),
                TextButton(
                  key: const ValueKey('advance-step'),
                  onPressed: () => setState(() => currentStep = 3),
                  child: const Text('Advance'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('advance-step')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Malipo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('order review line shows product, quantity, and server prices', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const Scaffold(
          body: CheckoutOrderLine(
            line: CartLine(
              product: ProductSummary(
                id: 1,
                name: 'Dove Beauty Soap',
                slug: 'dove-soap',
                categoryId: 1,
                price: 5000,
                priceFrom: 4500,
                moq: 1,
                sellerName: 'CHIMBO',
                isSellerVerified: true,
                isInStock: true,
              ),
              quantity: 6,
              unitPrice: 4800,
              tierMinQuantity: 3,
              lineTotal: 28800,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dove Beauty Soap'), findsOneWidget);
    expect(find.text('6 × TZS 4,800'), findsOneWidget);
    expect(find.text('TZS 28,800'), findsOneWidget);
    final productName = tester.widget<Text>(find.text('Dove Beauty Soap'));
    final lineTotal = tester.widget<Text>(find.text('TZS 28,800'));
    expect(productName.style?.fontWeight, isNot(FontWeight.w700));
    expect(lineTotal.style?.fontWeight, isNot(FontWeight.w700));
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed checkout total preview offers a retry', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: CheckoutPreviewSection(
            previewState: AsyncValue<CheckoutPreview?>.error(
              Exception('preview failed'),
              StackTrace.current,
            ),
            deliveryMethod: null,
            itemsLabel: 'Bidhaa',
            totalLabel: 'Jumla',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Jaribu tena'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jaribu tena'));
    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });
}
