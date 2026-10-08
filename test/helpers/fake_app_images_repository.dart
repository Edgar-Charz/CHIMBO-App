import 'package:chimbo/features/app_images/data/app_images_repository.dart';
import 'package:chimbo/features/app_images/data/models/app_image.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';

class FakeAppImagesRepository implements AppImagesRepository {
  FakeAppImagesRepository({
    Map<AppImageSlot, AppImage> cachedImages = const {},
    Map<AppImageSlot, AppImage> fetchedImages = const {},
    this.fetchError,
  }) : _cachedImages = Map.of(cachedImages),
       _fetchedImages = Map.of(fetchedImages);

  Map<AppImageSlot, AppImage> _cachedImages;
  final Map<AppImageSlot, AppImage> _fetchedImages;
  final Object? fetchError;
  int fetchCount = 0;

  @override
  Map<AppImageSlot, AppImage> readCachedImages() => Map.of(_cachedImages);

  @override
  Future<Map<AppImageSlot, AppImage>> fetchImages() async {
    fetchCount++;
    if (fetchError case final error?) throw error;
    return Map.of(_fetchedImages);
  }

  @override
  Future<void> saveImages(Map<AppImageSlot, AppImage> images) async {
    _cachedImages = Map.of(images);
  }
}
