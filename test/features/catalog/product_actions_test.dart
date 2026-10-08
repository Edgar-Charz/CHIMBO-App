import 'dart:async';

import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/application/product_actions.dart';
import 'package:chimbo/features/catalog/presentation/product_details_screen.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:chimbo/features/support/data/support_repository.dart';
import 'package:chimbo/features/wishlist/application/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_data.dart';

void main() {
  testWidgets('Share sends product name, price and its website URL', (
    tester,
  ) async {
    String? sharedText;
    await _pumpProductPage(
      tester,
      supportRepository: const _AvailableSupportRepository(),
      shareProduct: (text) async => sharedText = text,
      launchExternalUrl: (_) async => true,
    );

    await tester.tap(find.byTooltip('Shiriki'));
    await tester.pump();

    expect(
      sharedText,
      'Vaseline Petroleum Jelly 400ml — TZS 5,500 kwenye CHIMBO\n'
      'http://10.0.2.2/chimbo/p/101-vaseline-petroleum-jelly-400ml',
    );
  });

  testWidgets('Uliza Muuzaji retries support and launches its wa.me URL', (
    tester,
  ) async {
    final supportRepository = _LoadingSupportRepository();
    Uri? launchedUrl;
    await _pumpProductPage(
      tester,
      supportRepository: supportRepository,
      shareProduct: (_) async {},
      launchExternalUrl: (uri) async {
        launchedUrl = uri;
        return true;
      },
    );
    await tester.pump();

    expect(find.text('Uliza Muuzaji'), findsOneWidget);
    expect(supportRepository.requestCount, 1);

    await tester.tap(find.text('Uliza Muuzaji'));
    await tester.pumpAndSettle();

    expect(supportRepository.requestCount, 2);
    expect(launchedUrl?.scheme, 'https');
    expect(launchedUrl?.host, 'wa.me');
    expect(launchedUrl?.path, '/255700111222');
    expect(
      launchedUrl?.queryParameters['text'],
      'Habari CHIMBO, nina swali kuhusu Vaseline Petroleum Jelly 400ml: '
      'http://10.0.2.2/chimbo/p/101-vaseline-petroleum-jelly-400ml',
    );
    supportRepository.firstRequest.complete(
      const SupportContacts(
        phone: '+255700111222',
        whatsappUrl: 'https://wa.me/255700111222',
        hours: 'Jumatatu–Jumamosi',
      ),
    );
  });
}

Future<void> _pumpProductPage(
  WidgetTester tester, {
  required SupportRepository supportRepository,
  required ProductShare shareProduct,
  required ExternalUrlLauncher launchExternalUrl,
}) async {
  final details = devProductById(101).details;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productDetailsProvider(101).overrideWith((ref) async => details),
        supportRepositoryProvider.overrideWithValue(supportRepository),
        productShareProvider.overrideWithValue(shareProduct),
        externalUrlLauncherProvider.overrideWithValue(launchExternalUrl),
        wishlistControllerProvider.overrideWith(_EmptyWishlistController.new),
      ],
      child: const MaterialApp(
        locale: Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProductDetailsScreen(productId: 101),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _EmptyWishlistController extends WishlistController {
  @override
  Future<Set<int>> build() async => const {};
}

class _AvailableSupportRepository implements SupportRepository {
  const _AvailableSupportRepository();

  @override
  Future<SupportContacts> getContacts() async => const SupportContacts(
    phone: '+255700111222',
    whatsappUrl: 'https://wa.me/255700111222',
    hours: 'Jumatatu–Jumamosi',
  );

  @override
  Future<LegalPage> getPage(LegalPageType type) async =>
      LegalPage(title: '', paragraphs: const [], updatedAt: DateTime(2026));
}

class _LoadingSupportRepository implements SupportRepository {
  int requestCount = 0;
  final Completer<SupportContacts> firstRequest = Completer<SupportContacts>();

  @override
  Future<SupportContacts> getContacts() async {
    requestCount++;
    if (requestCount == 1) {
      return firstRequest.future;
    }
    return const SupportContacts(
      phone: '+255700111222',
      whatsappUrl: 'https://wa.me/255700111222',
      hours: 'Jumatatu–Jumamosi',
    );
  }

  @override
  Future<LegalPage> getPage(LegalPageType type) async =>
      LegalPage(title: '', paragraphs: const [], updatedAt: DateTime(2026));
}
