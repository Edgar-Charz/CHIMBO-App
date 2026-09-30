import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/features/catalog/data/models/product_photo.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

/// Swipeable product photos with a zoom button and thumbnails (design PDF p.6).
/// Without photos it shows the placeholder alone.
class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.photos});

  /// Medium for the big photo, thumb for the strip, large for zoom.
  final List<ProductPhoto> photos;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openZoom() {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _ZoomDialog(imageUrl: widget.photos[_currentIndex].largeUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photos.isEmpty)
                const AppNetworkImage(
                  url: null,
                  placeholderIcon: ProductCard.placeholderIcon,
                )
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: photos.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) => AppNetworkImage(
                    url: photos[index].mediumUrl,
                    placeholderIcon: ProductCard.placeholderIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              if (photos.isNotEmpty)
                Positioned(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: IconButton.filledTonal(
                    onPressed: _openZoom,
                    tooltip: context.l10n.actionZoom,
                    icon: const Icon(Icons.zoom_in_rounded),
                  ),
                ),
            ],
          ),
        ),
        if (photos.length > 1)
          _Thumbnails(
            photos: photos,
            currentIndex: _currentIndex,
            onTap: (index) => _pageController.animateToPage(
              index,
              duration: AppDurations.medium,
              curve: Curves.easeInOut,
            ),
          ),
      ],
    );
  }
}

class _Thumbnails extends StatelessWidget {
  const _Thumbnails({
    required this.photos,
    required this.currentIndex,
    required this.onTap,
  });

  final List<ProductPhoto> photos;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.galleryThumbnail + AppSpacing.lg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            width: AppSizes.galleryThumbnail,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: index == currentIndex
                    ? AppColors.primary
                    : AppColors.border,
                width: index == currentIndex ? 2 : 1,
              ),
            ),
            child: AppNetworkImage(
              url: photos[index].thumbUrl,
              placeholderIcon: ProductCard.placeholderIcon,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen photo with pinch-to-zoom (Flutter's built-in InteractiveViewer).
class _ZoomDialog extends StatelessWidget {
  const _ZoomDialog({required this.imageUrl});

  static const double _maxScale = 4;

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        children: [
          InteractiveViewer(
            maxScale: _maxScale,
            child: Center(
              child: AppNetworkImage(
                url: imageUrl,
                placeholderIcon: ProductCard.placeholderIcon,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
