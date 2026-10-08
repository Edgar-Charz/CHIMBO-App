import 'dart:convert';

import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/app_images/data/app_images_repository.dart';
import 'package:chimbo/features/app_images/data/models/app_image.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads admin-managed illustrations from the public `/app-images` endpoint.
class ApiAppImagesRepository implements AppImagesRepository {
  const ApiAppImagesRepository(this._apiClient, this._preferences);

  static const String _cacheKey = 'app_image_urls';

  final ApiClient _apiClient;
  final SharedPreferences _preferences;

  @override
  Map<AppImageSlot, AppImage> readCachedImages() {
    final cachedJson = _preferences.getString(_cacheKey);
    if (cachedJson == null) return const {};

    try {
      final cached = jsonDecode(cachedJson) as List<dynamic>;
      final images = <AppImageSlot, AppImage>{};
      for (final item in cached) {
        final image = AppImage.fromJson(item as Map<String, dynamic>);
        final slot = image.slot;
        if (slot != null && image.url.isNotEmpty) {
          images[slot] = image;
        }
      }
      return images;
    } on FormatException {
      return const {};
    } on TypeError {
      return const {};
    }
  }

  @override
  Future<Map<AppImageSlot, AppImage>> fetchImages() async {
    final response = await _apiClient.get('/app-images');
    final images = <AppImageSlot, AppImage>{};
    for (final item in response.dataAsList) {
      final json = item as Map<String, dynamic>;
      final image = AppImage.fromJson(json);
      final slot = image.slot;
      if (slot != null && image.url.isNotEmpty) {
        images[slot] = image;
      }
    }
    return images;
  }

  @override
  Future<void> saveImages(Map<AppImageSlot, AppImage> images) async {
    final values = images.values.map((image) => image.toJson()).toList();
    await _preferences.setString(_cacheKey, jsonEncode(values));
  }
}
