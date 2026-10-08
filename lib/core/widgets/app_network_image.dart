import 'package:cached_network_image/cached_network_image.dart';
import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/widgets/image_placeholder.dart';
import 'package:flutter/material.dart';

/// A server image (product photos), cached on the phone so it downloads only once.
/// Shows [placeholderIcon] while loading, on error, and when there is no photo yet.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.placeholderIcon,
    this.placeholderIcons,
    this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.iconsWhileLoading = true,
  });

  final String? url;
  final IconData placeholderIcon;
  final List<IconData>? placeholderIcons;
  final String? fallbackAsset;
  final BoxFit fit;
  final Alignment alignment;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final Duration fadeInDuration;

  /// False: a plain soft background while the picture downloads; the fallback (asset or
  /// icons) only when there is no picture or it fails.
  final bool iconsWhileLoading;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    Widget fallback() {
      final asset = fallbackAsset;
      if (asset == null) {
        return ImagePlaceholder(icons: placeholderIcons ?? [placeholderIcon]);
      }
      return Image.asset(
        asset,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, _, _) =>
            ImagePlaceholder(icons: placeholderIcons ?? [placeholderIcon]),
      );
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return fallback();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      // Same tunnel header as the API, or ngrok sends a warning page instead of the image.
      httpHeaders: Env.tunnelHeaders,
      fit: fit,
      alignment: alignment,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      fadeInDuration: fadeInDuration,
      placeholder: (_, _) =>
          iconsWhileLoading ? fallback() : const ImagePlaceholder(icons: []),
      errorWidget: (_, _, _) => fallback(),
    );
  }
}
