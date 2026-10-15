import 'package:cached_network_image/cached_network_image.dart';
import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/widgets/image_placeholder.dart';
import 'package:flutter/material.dart';

/// A server image cached on the phone, with a soft loading background by default.
/// Shows [placeholderIcon] when there is no photo or loading fails.
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
    this.previewUrl,
    this.previewMemCacheWidth,
    this.previewMemCacheHeight,
    this.previewMaxWidthDiskCache,
    this.previewMaxHeightDiskCache,
    this.fadeInDuration = const Duration(milliseconds: 120),
    this.iconsWhileLoading = false,
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
  final String? previewUrl;
  final int? previewMemCacheWidth;
  final int? previewMemCacheHeight;
  final int? previewMaxWidthDiskCache;
  final int? previewMaxHeightDiskCache;
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
    Widget preview() {
      final lowResolutionUrl = previewUrl;
      if (lowResolutionUrl == null || lowResolutionUrl.isEmpty) {
        return iconsWhileLoading
            ? fallback()
            : const ImagePlaceholder(icons: []);
      }
      return CachedNetworkImage(
        imageUrl: lowResolutionUrl,
        httpHeaders: Env.tunnelHeaders,
        fit: fit,
        alignment: alignment,
        fadeInDuration: Duration.zero,
        memCacheWidth: previewMemCacheWidth,
        memCacheHeight: previewMemCacheHeight,
        maxWidthDiskCache: previewMaxWidthDiskCache,
        maxHeightDiskCache: previewMaxHeightDiskCache,
        placeholder: (_, _) => const ImagePlaceholder(icons: []),
        errorWidget: (_, _, _) => fallback(),
      );
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
      placeholder: (_, _) => preview(),
      errorWidget: (_, _, _) => previewUrl == null ? fallback() : preview(),
    );
  }
}
