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
    this.fit = BoxFit.cover,
  });

  final String? url;
  final IconData placeholderIcon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    final placeholder = ImagePlaceholder(icons: [placeholderIcon]);
    if (imageUrl == null) {
      return placeholder;
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      // Same tunnel header as the API, or ngrok sends a warning page instead of the image.
      httpHeaders: Env.tunnelHeaders,
      fit: fit,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
