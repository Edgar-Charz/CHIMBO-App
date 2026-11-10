import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/presentation/widgets/listing_controls.dart';
import 'package:chimbo/features/home/presentation/widgets/home_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home category cards lead with imagery and remain tappable', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var wasOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold( 
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 12,
              children: [
                for (var index = 0; index < 2; index++)
                  Expanded(
                    child: CategoryCard(
                      category: Category(
                        id: index + 1,
                        name: index == 0 ? 'Cosmetics' : 'Jewelry',
                        tagline: index == 0
                            ? 'Shamba la Vipodozi'
                            : 'Vito vya Urembo',
                      ),
                      image: '',
                      placeholderIcon: Icons.shopping_bag_outlined,
                      background: Colors.white,
                      onBrowse: () => wasOpened = true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('COSMETICS'), findsOneWidget);
    expect(find.text('Shamba la Vipodozi'), findsOneWidget);
    expect(find.text('Angalia'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Angalia').first);
    expect(wasOpened, isTrue);
  });

  testWidgets('Discover category chips show the selected category clearly', (
    tester,
  ) async {
    int? selectedCategory;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: CategoryChips(
            categories: const [
              Category(id: 1, name: 'Cosmetics'),
              Category(id: 2, name: 'Jewelry'),
            ],
            selectedId: 1,
            onSelected: (id) => selectedCategory = id,
          ),
        ),
      ),
    );

    final selectedChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Cosmetics'),
    );
    expect(selectedChip.selected, isTrue);
    expect(selectedChip.avatar, isA<Icon>());

    await tester.tap(find.text('Jewelry'));
    expect(selectedCategory, 2);
  });

  testWidgets('compact product section heading uses tighter spacing and type', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SectionHeader(
            title: 'Price reductions',
            actionLabel: 'View all',
            isCompact: true,
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Price reductions'));
    final headerPadding = tester.widget<Padding>(
      find.ancestor(of: find.byType(Row), matching: find.byType(Padding)).first,
    );
    expect(
      title.style?.fontSize,
      AppTheme.light().textTheme.titleSmall?.fontSize,
    );
    expect(headerPadding.padding, const EdgeInsets.only(bottom: AppSpacing.xs));
  });
}
