import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/features/home/data/home_data.dart';
import 'package:chimbo/features/home/presentation/widgets/home_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const banners = [
    HomeBanner(title: 'Bei za jumla', buttonLabel: 'Nunua ya kwanza'),
    HomeBanner(title: 'Ofa za wiki', buttonLabel: 'Nunua ya pili'),
  ];

  Future<void> pumpCarousel(
    WidgetTester tester, {
    required ValueChanged<HomeBanner> onBannerTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: HomeBannerCarousel(banners: banners, onBannerTap: onBannerTap),
        ),
      ),
    );
  }

  testWidgets('multiple home banners show tappable page indicators', (
    tester,
  ) async {
    HomeBanner? tappedBanner;
    await pumpCarousel(tester, onBannerTap: (banner) => tappedBanner = banner);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-banner-dot-1')), findsOneWidget);
    expect(find.text('Bei za jumla'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-banner-dot-1')));
    await tester.pumpAndSettle();
    expect(find.text('Ofa za wiki'), findsOneWidget);

    await tester.tap(find.text('Nunua ya pili'));
    expect(tappedBanner, banners[1]);
  });

  testWidgets(
    'home banner carousel advances automatically after five seconds',
    (tester) async {
      await pumpCarousel(tester, onBannerTap: (_) {});

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Ofa za wiki'), findsOneWidget);
    },
  );

  testWidgets('banner content fits without overflow at narrow widths', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: WholesaleBanner(
                banner: const HomeBanner(
                  title: 'WHOLESALE PRICES',
                  subtitle: 'The more you buy, the more you save',
                  buttonLabel: 'Shop now',
                ),
                onShopNow: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(WholesaleBanner)).height,
      AppSizes.bannerHeight,
    );
    final button = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.height == AppSizes.bannerButtonHeight,
      ),
    );
    expect(button.height, AppSizes.bannerButtonHeight);
    expect(tester.takeException(), isNull);
  });
}
