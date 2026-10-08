import 'package:chimbo/features/app_images/data/models/app_image.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';

/// Reads replaceable illustrations and the last successfully fetched URL list.
abstract interface class AppImagesRepository {
  Map<AppImageSlot, AppImage> readCachedImages();

  Future<Map<AppImageSlot, AppImage>> fetchImages();

  Future<void> saveImages(Map<AppImageSlot, AppImage> images);
}
