import 'package:chimbo/features/app_images/data/app_images_providers.dart';
import 'package:chimbo/features/app_images/data/models/app_image.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the cached picture URLs and refreshes them without blocking app startup.
class AppImagesController extends Notifier<Map<AppImageSlot, AppImage>> {
  @override
  Map<AppImageSlot, AppImage> build() =>
      ref.watch(appImagesRepositoryProvider).readCachedImages();

  Future<void> refresh() async {
    final repository = ref.read(appImagesRepositoryProvider);
    try {
      final images = await repository.fetchImages();
      await repository.saveImages(images);
      state = images;
    } catch (_) {
      // Keep saved URLs; each image slot still has a bundled asset fallback.
    }
  }
}

final appImagesControllerProvider =
    NotifierProvider<AppImagesController, Map<AppImageSlot, AppImage>>(
      AppImagesController.new,
    );
