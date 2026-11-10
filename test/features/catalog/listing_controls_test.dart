import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/features/catalog/presentation/widgets/listing_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filter and sort controls use a compact centered layout', (
    tester,
  ) async {
    var filterOpened = false;
    var sortOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FilterBar(
              activeFilterCount: 2,
              onFilter: () => filterOpened = true,
              onSort: () => sortOpened = true,
            ),
          ),
        ),
      ),
    );

    final filterButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Chuja'),
    );
    final sortButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Panga'),
    );

    expect(
      filterButton.style?.minimumSize?.resolve({})?.height,
      AppSizes.compactControl,
    );
    expect(
      sortButton.style?.minimumSize?.resolve({})?.height,
      AppSizes.compactControl,
    );
    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(2));

    await tester.tap(find.text('Chuja'));
    await tester.tap(find.text('Panga'));

    expect(filterOpened, isTrue);
    expect(sortOpened, isTrue);
    expect(tester.takeException(), isNull);
  });
}
