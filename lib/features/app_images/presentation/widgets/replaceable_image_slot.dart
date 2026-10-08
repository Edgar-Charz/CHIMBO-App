import 'package:cached_network_image/cached_network_image.dart';
import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/features/app_images/application/app_images_controller.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a cached server illustration when available, using the bundled asset as its fallback.
class ReplaceableImageSlot extends ConsumerWidget {
  const ReplaceableImageSlot({
    super.key,
    required this.slot,
    required this.asset,
    required this.placeholderIcons,
    this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
  });

  final AppImageSlot slot;
  final String asset;
  final List<IconData> placeholderIcons;
  final BorderRadius borderRadius;
  final Alignment alignment;
  final BoxFit fit;

  /// Pictures are kept at most this size (in pixels) on disk and in memory.
  static const int _cacheDimension = 1200;

  /// Downloads [url] and keeps it decoded in memory under the same key this widget uses, so
  /// a screen opened afterwards shows it in its first frame. Never throws: on failure the
  /// slot simply loads (or falls back) as usual.
  static Future<void> precache(BuildContext context, String url) {
    return precacheImage(
      ResizeImage.resizeIfNeeded(
        _cacheDimension,
        _cacheDimension,
        CachedNetworkImageProvider(
          url,
          headers: Env.tunnelHeaders,
          maxWidth: _cacheDimension,
          maxHeight: _cacheDimension,
        ),
      ),
      context,
      onError: (_, _) {},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(
      appImagesControllerProvider.select((images) => images[slot]?.url),
    );
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox.expand(
        child: AppNetworkImage(
          url: imageUrl,
          fallbackAsset: asset,
          placeholderIcon: placeholderIcons.first,
          placeholderIcons: placeholderIcons,
          fit: fit,
          alignment: alignment,
          memCacheWidth: _cacheDimension,
          memCacheHeight: _cacheDimension,
          maxWidthDiskCache: _cacheDimension,
          maxHeightDiskCache: _cacheDimension,
          fadeInDuration: Duration.zero,
          iconsWhileLoading: false,
        ),
      ),
    );
  }
}
