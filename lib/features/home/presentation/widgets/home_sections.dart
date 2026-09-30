import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/core/widgets/image_slot.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/home/data/home_data.dart';
import 'package:flutter/material.dart';

/// One of the two big category cards ("COSMETICS — Shamba la Vipodozi — Angalia →").
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.image,
    this.imageUrl,
    required this.placeholderIcon,
    required this.background,
    required this.onBrowse,
  });

  final Category category;
  final String image;
  final String? imageUrl;
  final IconData placeholderIcon;
  final Color background;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tagline = category.tagline;
    return Card(
      elevation: 0,
      color: background,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBrowse,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                category.name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tagline != null)
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppSizes.categoryCardImage,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: imageUrl == null
                      ? ImageSlot(
                          asset: image,
                          placeholderIcons: [placeholderIcon],
                        )
                      : AppNetworkImage(
                          url: imageUrl,
                          placeholderIcon: placeholderIcon,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: AppSizes.compactControl,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onBrowse,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    minimumSize: const Size.fromHeight(AppSizes.compactControl),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    context.l10n.actionBrowse,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round coloured icon with a label (Ofa, Bidhaa Mpya, …).
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              CircleAvatar(
                radius: AppSizes.quickActionIcon / 2,
                backgroundColor: background,
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "BEI ZA JUMLA — Nunua zaidi, okoa zaidi! — Nunua Sasa →" with a picture on the right.
class WholesaleBanner extends StatelessWidget {
  const WholesaleBanner({super.key, required this.onShopNow, this.banner});

  final VoidCallback onShopNow;
  final HomeBanner? banner;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: AppColors.goldLight,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 104,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner?.title.isNotEmpty == true
                          ? banner!.title
                          : l10n.bannerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if ((banner?.subtitle ?? '').isNotEmpty)
                      Text(
                        banner!.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      )
                    else if (banner == null)
                      Text(
                        l10n.bannerSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: AppSizes.compactControl,
                      child: FilledButton.icon(
                        onPressed: onShopNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          minimumSize: const Size(0, AppSizes.compactControl),
                          shape: const StadiumBorder(),
                          textStyle: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        iconAlignment: IconAlignment.end,
                        label: Text(
                          banner?.buttonLabel?.isNotEmpty == true
                              ? banner!.buttonLabel!
                              : l10n.actionShopNow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: AppSizes.bannerImageWidth,
              child: banner?.imageUrl == null
                  ? const ImageSlot(
                      asset: AppImages.homeWholesaleBanner,
                      placeholderIcons: [Icons.inventory_2_outlined],
                    )
                  : AppNetworkImage(
                      url: banner!.imageUrl,
                      placeholderIcon: Icons.inventory_2_outlined,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
