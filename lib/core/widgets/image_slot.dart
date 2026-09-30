import 'package:chimbo/core/widgets/image_placeholder.dart';
import 'package:flutter/material.dart';

/// A fixed-size frame for a design picture. By default the picture fills the frame
/// ([BoxFit.cover]), so any image with the recommended framing fits without stretching;
/// [BoxFit.contain] shows the whole picture instead (logos).
///
/// Until the file exists in `assets/images/`, the frame shows [placeholderIcons] on a soft
/// gradient instead.
class ImageSlot extends StatelessWidget {
  const ImageSlot({
    super.key,
    required this.asset,
    required this.placeholderIcons,
    this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final List<IconData> placeholderIcons;
  final BorderRadius borderRadius;

  /// Which part of the picture stays visible when the frame crops it.
  final Alignment alignment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox.expand(
        child: Image.asset(
          asset,
          fit: fit,
          alignment: alignment,
          errorBuilder: (_, _, _) => ImagePlaceholder(icons: placeholderIcons),
        ),
      ),
    );
  }
}
