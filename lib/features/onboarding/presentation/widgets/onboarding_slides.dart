import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/image_slot.dart';
import 'package:chimbo/core/widgets/separated_text.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/category_pill.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/savings_seal.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/tier_preview_card.dart';
import 'package:flutter/material.dart';

const BorderRadius _pictureRadius = BorderRadius.all(
  Radius.circular(AppRadius.large),
);

/// Slide 1 — "Bidhaa za Biashara Yako".
class ProductsSlide extends StatelessWidget {
  const ProductsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingSlide(
      title: l10n.onboardingProductsTitle,
      subtitle: Text(l10n.onboardingProductsSubtitle),
      header: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.md,
        children: [
          CategoryPill(label: l10n.categoryJewelry),
          CategoryPill(label: l10n.categoryCosmetics),
        ],
      ),
      illustration: const ImageSlot(
        asset: AppImages.onboardingProducts,
        placeholderIcons: [Icons.diamond_outlined, Icons.spa_outlined],
        borderRadius: _pictureRadius,
      ),
    );
  }
}

/// Slide 2 — "Bei za Jumla Zinazokulipa", with an example price ladder over the picture.
class WholesaleSlide extends StatelessWidget {
  const WholesaleSlide({super.key});

  // Illustrative only (blueprint I-1): real tiers always come from the server.
  static const List<ExampleTier> _exampleTiers = [
    (minimumQuantity: 6, unitPrice: 5500),
    (minimumQuantity: 24, unitPrice: 5000),
    (minimumQuantity: 60, unitPrice: 4400),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingSlide(
      title: l10n.onboardingWholesaleTitle,
      subtitle: Text(l10n.onboardingWholesaleSubtitle),
      illustration: const Stack(
        children: [
          // The card covers the lower part, so the picture keeps its top in view.
          ImageSlot(
            asset: AppImages.onboardingWholesale,
            placeholderIcons: [Icons.inventory_2_outlined],
            borderRadius: _pictureRadius,
            alignment: Alignment.topCenter,
          ),
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: SavingsSeal(),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: TierPreviewCard(tiers: _exampleTiers),
          ),
        ],
      ),
    );
  }
}

/// Slide 3 — "Agiza kwa Urahisi. Pokea Haraka."
class DeliverySlide extends StatelessWidget {
  const DeliverySlide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingSlide(
      title: l10n.onboardingDeliveryTitle,
      subtitle: SeparatedText(
        parts: [
          l10n.onboardingStepChoose,
          l10n.onboardingStepPay,
          l10n.onboardingStepReceive,
        ],
      ),
      illustration: const ImageSlot(
        asset: AppImages.onboardingDelivery,
        placeholderIcons: [
          Icons.storefront_outlined,
          Icons.local_shipping_outlined,
        ],
        borderRadius: _pictureRadius,
      ),
      footer: const _DeliveryPromise(),
    );
  }
}

/// Shield + "Tunafikisha oda yako salama na kwa wakati."
class _DeliveryPromise extends StatelessWidget {
  const _DeliveryPromise();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: AppSizes.iconMedium,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            context.l10n.onboardingDeliveryPromise,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
