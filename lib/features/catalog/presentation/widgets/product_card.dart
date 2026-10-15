import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/core/widgets/price_text.dart';
import 'package:chimbo/features/cart/presentation/quick_add_sheet.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/data/models/product_offer.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/offer_widgets.dart';
import 'package:chimbo/features/wishlist/presentation/wishlist_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The one product card used everywhere (blueprint I-7): square picture with one badge and the
/// heart, 2-line name, price (with the old price on deals), MOQ with the verified tick, and the
/// round (+). The wholesale tiers are on the product page.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  static const IconData placeholderIcon = Icons.inventory_2_outlined;

  /// Shape-only stand-in; `Skeletonizer` draws it as grey blocks while lists load.
  static const ProductSummary skeletonProduct = ProductSummary(
    id: 0,
    name: 'Jina la bidhaa ya mfano',
    slug: '',
    categoryId: 0,
    price: 5500,
    priceFrom: 4400,
    moq: 1,
    sellerName: '',
    isSellerVerified: true,
    isInStock: true,
  );

  final ProductSummary product;

  void _open(BuildContext context) {
    context.push(AppRoutes.productDetails(product.id));
  }

  @override
  Widget build(BuildContext context) {
    // Soft shadow instead of a border lifts the white card off the cream page.
    return Card(
      elevation: AppSizes.cardElevation,
      shadowColor: AppColors.cardShadow,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _open(context),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    url: product.imageUrl,
                    placeholderIcon: placeholderIcon,
                    memCacheWidth: 480,
                    memCacheHeight: 480,
                    maxWidthDiskCache: 480,
                    maxHeightDiskCache: 480,
                  ),
                  if (product.isInStock)
                    // Bottom-left, so the heart has the top-right to itself on narrow cards.
                    Positioned(
                      left: AppSpacing.sm,
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _CardBadge(product: product),
                      ),
                    )
                  else
                    const _SoldOutCover(),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: WishlistButton(productId: product.id),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: _CardInfo(
              product: product,
              onProductTap: () => _open(context),
              onQuickAdd: product.isInStock
                  ? () => showQuickAddSheet(context, product)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Name, price and MOQ beside the (+).
class _CardInfo extends StatelessWidget {
  const _CardInfo({
    required this.product,
    required this.onProductTap,
    required this.onQuickAdd,
  });

  final ProductSummary product;
  final VoidCallback onProductTap;

  /// Null when sold out (the (+) is disabled).
  final VoidCallback? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final oldPrice = product.compareAtPrice;
    final secondary = textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onProductTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    PriceText(
                      product.price,
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (oldPrice != null &&
                        product.discountPercent != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        Money.format(oldPrice),
                        style: secondary?.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textSecondary,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.productMoq(product.moq),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: secondary?.copyWith(fontSize: 11),
                    ),
                  ),
                  if (product.isSellerVerified) const _VerifiedTick(),
                ],
              ),
            ),
            _QuickAddButton(onPressed: onQuickAdd),
          ],
        ),
      ],
    );
  }
}

/// One badge at most (§6.2): a time-limited offer ("Ofa −15%" and its countdown), else
/// "-17%" for a deal, otherwise Inauzwa Sana / Mpya / Ofa.
class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (product.offer case final offer?) {
      return _OfferBadge(offer: offer);
    }
    final discount = product.discountPercent;
    if (discount != null) {
      return _Pill(
        label: l10n.discountPercent(discount),
        foreground: AppColors.onDanger,
        background: AppColors.danger,
      );
    }
    return switch (product.badge) {
      ProductBadge.bestseller => _Pill(
        label: l10n.badgeBestseller,
        icon: Icons.star_rounded,
        foreground: AppColors.accent,
        background: AppColors.surface,
      ),
      ProductBadge.newArrival => _Pill(
        label: l10n.badgeNew,
        icon: Icons.auto_awesome_rounded,
        foreground: AppColors.info,
        background: AppColors.surface,
      ),
      // Without its offer data (just ended) the badge has nothing to show.
      ProductBadge.offer => const SizedBox.shrink(),
      ProductBadge.deal => _Pill(
        label: l10n.badgeDeal,
        icon: Icons.local_offer_rounded,
        foreground: AppColors.danger,
        background: AppColors.surface,
      ),
      null => const SizedBox.shrink(),
    };
  }
}

/// "Ofa −15%" with "Inaisha baada ya saa 5" under it, on the picture. When the offer ends
/// the lists reload, so the card shows the server's price again.
class _OfferBadge extends ConsumerWidget {
  const _OfferBadge({required this.offer});

  final ProductOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OfferLabel(percent: offer.percent),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs / 2,
            ),
            child: OfferCountdown(
              endsAt: offer.endsAt,
              onEnded: ref.reloadCatalogPrices,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final leading = icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: AppSizes.iconSmall, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Faded picture with a dark "Imeisha" pill: the product can't be ordered right now.
class _SoldOutCover extends StatelessWidget {
  const _SoldOutCover();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface.withValues(alpha: 0.6),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              context.l10n.outOfStock,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.surface),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round orange (+): opens the quick-add sheet.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Filled orange (orange = buy); compact, so it sits beside the MOQ without making the
    // card taller.
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: context.l10n.actionAddToCart,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.border,
      ),
      icon: const Icon(Icons.add_rounded),
    );
  }
}

/// Green tick beside the MOQ; the words "Muuzaji Aliyethibitishwa" are in the listing header.
class _VerifiedTick extends StatelessWidget {
  const _VerifiedTick();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Icon(
        Icons.verified_rounded,
        size: AppSizes.iconSmall,
        color: AppColors.success,
        semanticLabel: context.l10n.verifiedSeller,
      ),
    );
  }
}
