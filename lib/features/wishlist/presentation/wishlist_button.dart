import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/wishlist/application/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The heart: outline when not saved, red and filled (with a small pop) when saved.
/// [onImage] draws it in a white circle so it shows on any photo.
class WishlistButton extends ConsumerWidget {
  const WishlistButton({
    super.key,
    required this.productId,
    this.onImage = true,
  });

  final int productId;
  final bool onImage;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final toast = AppToast.of(context);
    final l10n = context.l10n;
    try {
      final isSaved = await ref
          .read(wishlistControllerProvider.notifier)
          .toggle(productId);
      if (isSaved) {
        toast.success(l10n.savedToWishlist);
      }
    } on ApiException catch (error) {
      toast.error(l10n.errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isSaved = ref.watch(
      wishlistControllerProvider.select(
        (saved) => saved.value?.contains(productId) ?? false,
      ),
    );
    final heart = AnimatedSwitcher(
      duration: AppDurations.fast,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(isSaved),
        color: isSaved ? AppColors.danger : AppColors.textPrimary,
        size: onImage ? AppSizes.iconMedium : null,
      ),
    );
    return IconButton(
      onPressed: () => _toggle(context, ref),
      tooltip: isSaved ? l10n.actionUnfavourite : l10n.actionFavourite,
      visualDensity: onImage ? VisualDensity.compact : null,
      style: onImage
          ? IconButton.styleFrom(
              backgroundColor: AppColors.surface.withValues(alpha: 0.96),
              minimumSize: const Size(40, 40),
              maximumSize: const Size(40, 40),
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            )
          : null,
      icon: heart,
    );
  }
}
