import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/features/app_images/application/app_images_controller.dart';
import 'package:chimbo/features/app_images/data/app_images_providers.dart';
import 'package:chimbo/features/app_images/data/models/app_image.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/app_images/presentation/widgets/replaceable_image_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_app_images_repository.dart';

void main() {
  test('refresh saves new image URLs and publishes them to the app', () async {
    const fetched = {
      AppImageSlot.onboardingDelivery: AppImage(
        slot: AppImageSlot.onboardingDelivery,
        url: 'https://images.test/delivery-v2.webp',
        updatedAt: '2026-10-06T10:00:00+00:00',
      ),
    };
    final repository = FakeAppImagesRepository(fetchedImages: fetched);
    final container = ProviderContainer(
      overrides: [appImagesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(appImagesControllerProvider.notifier).refresh();

    expect(repository.fetchCount, 1);
    expect(repository.readCachedImages(), fetched);
    expect(container.read(appImagesControllerProvider), fetched);
  });

  test(
    'a failed refresh keeps the saved URLs available for offline use',
    () async {
      const cached = {
        AppImageSlot.orderSuccess: AppImage(
          slot: AppImageSlot.orderSuccess,
          url: 'https://images.test/order-v1.webp',
          updatedAt: '2026-10-06T10:00:00+00:00',
        ),
      };
      final repository = FakeAppImagesRepository(
        cachedImages: cached,
        fetchError: StateError('offline'),
      );
      final container = ProviderContainer(
        overrides: [appImagesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(container.read(appImagesControllerProvider), cached);
      await container.read(appImagesControllerProvider.notifier).refresh();

      expect(repository.fetchCount, 1);
      expect(container.read(appImagesControllerProvider), cached);
    },
  );

  testWidgets('uses the bundled illustration when no URL is cached', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appImagesRepositoryProvider.overrideWithValue(
            FakeAppImagesRepository(),
          ),
        ],
        child: const MaterialApp(
          home: SizedBox(
            width: 320,
            height: 200,
            child: ReplaceableImageSlot(
              slot: AppImageSlot.onboardingProducts,
              asset: 'assets/images/onboarding/products.png',
              placeholderIcons: [Icons.diamond_outlined],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/onboarding/products.png',
      ),
      findsOneWidget,
    );
    final image = tester.widget<AppNetworkImage>(find.byType(AppNetworkImage));
    expect(image.memCacheWidth, 1200);
    expect(image.memCacheHeight, 1200);
    expect(image.maxWidthDiskCache, 1200);
    expect(image.maxHeightDiskCache, 1200);
    expect(image.fadeInDuration, Duration.zero);
  });
}
