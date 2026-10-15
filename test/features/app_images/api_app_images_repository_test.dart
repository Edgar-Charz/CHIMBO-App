import 'package:chimbo/features/app_images/data/api_app_images_repository.dart';
import 'package:chimbo/features/app_images/data/models/app_image.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_http.dart';

void main() {
  test(
    'reads supported slots from GET /app-images and saves their URLs',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': [
            {
              'app_image_slot': 'onboarding_products',
              'app_image_url': 'https://images.test/products-v2.webp',
              'updated_at': '2026-10-06T10:00:00+00:00',
            },
            {
              'app_image_slot': 'auth_welcome',
              'app_image_url': 'https://images.test/welcome-v3.webp',
              'updated_at': '2026-10-06T10:01:00+00:00',
            },
            {
              'app_image_slot': 'future_slot',
              'app_image_url': 'https://images.test/future.webp',
              'updated_at': '2026-10-06T10:02:00+00:00',
            },
          ],
        }),
      );
      final repository = ApiAppImagesRepository(client, preferences);

      final images = await repository.fetchImages();
      await repository.saveImages(images);

      expect(adapter.lastRequest!.uri.path, endsWith('/app-images'));
      expect(images, {
        AppImageSlot.onboardingProducts: const AppImage(
          slot: AppImageSlot.onboardingProducts,
          url: 'https://images.test/products-v2.webp',
          updatedAt: '2026-10-06T10:00:00+00:00',
        ),
        AppImageSlot.authWelcome: const AppImage(
          slot: AppImageSlot.authWelcome,
          url: 'https://images.test/welcome-v3.webp',
          updatedAt: '2026-10-06T10:01:00+00:00',
        ),
      });
      expect(repository.readCachedImages(), images);
    },
  );

  test('the logo uploaded in the admin comes as slot "logo"', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [
          {
            'app_image_slot': 'logo',
            'app_image_url': 'https://images.test/brand/new-512.png',
            'updated_at': '2026-10-15T10:48:00+00:00',
          },
        ],
      }),
    );

    final images = await ApiAppImagesRepository(
      client,
      preferences,
    ).fetchImages();

    expect(
      images[AppImageSlot.logo]?.url,
      'https://images.test/brand/new-512.png',
    );
    expect(AppImageSlot.beforeHome, contains(AppImageSlot.logo));
  });
}
