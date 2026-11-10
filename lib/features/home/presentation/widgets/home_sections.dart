import 'dart:async';

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
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(color: background.withValues(alpha: 0.7)),
      ),
      child: SizedBox(
        height: AppSizes.homeCategoryCard,
        child: InkWell(
          onTap: onBrowse,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: background,
                child: imageUrl == null
                    ? ImageSlot(
                        asset: image,
                        placeholderIcons: [placeholderIcon],
                      )
                    : AppNetworkImage(
                        url: imageUrl,
                        fallbackAsset: image,
                        placeholderIcon: placeholderIcon,
                        fit: BoxFit.cover,
                      ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.9),
                    ],
                    stops: const [0.35, 0.58, 1],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (tagline != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.84),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          context.l10n.actionBrowse,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: AppSizes.iconSmall,
                          color: AppColors.onPrimary,
                        ),
                      ],
                    ),
                  ],
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

/// Rotates active Home banners and shows the current position.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  final List<HomeBanner> banners;
  final ValueChanged<HomeBanner> onBannerTap;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoAdvanceTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _currentIndex = _currentIndex.clamp(0, widget.banners.length - 1);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    if (widget.banners.length < 2) {
      return;
    }
    _autoAdvanceTimer = Timer.periodic(
      AppDurations.bannerCarousel,
      (_) => _advanceBanner(),
    );
  }

  void _advanceBanner() {
    if (!_pageController.hasClients || !mounted) {
      return;
    }
    final nextIndex = (_currentIndex + 1) % widget.banners.length;
    _pageController.animateToPage(
      nextIndex,
      duration: AppDurations.medium,
      curve: Curves.easeInOut,
    );
  }

  void _showBanner(int index) {
    _pageController.animateToPage(
      index,
      duration: AppDurations.medium,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: AppSizes.bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return WholesaleBanner(
                banner: banner,
                onShopNow: () => widget.onBannerTap(banner),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < widget.banners.length; index++)
              Semantics(
                button: true,
                selected: index == _currentIndex,
                label: widget.banners[index].title.isNotEmpty
                    ? widget.banners[index].title
                    : context.l10n.bannerTitle,
                child: InkWell(
                  key: ValueKey('home-banner-dot-$index'),
                  borderRadius: BorderRadius.circular(AppSizes.pageDot),
                  onTap: () => _showBanner(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      width: index == _currentIndex
                          ? AppSizes.pageDotActiveWidth
                          : AppSizes.pageDot,
                      height: AppSizes.pageDot,
                      decoration: BoxDecoration(
                        color: index == _currentIndex
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSizes.pageDot),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
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
        height: AppSizes.bannerHeight,
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
                      style: textTheme.titleMedium?.copyWith(
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
                        style: textTheme.bodyMedium,
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
                      height: AppSizes.bannerButtonHeight,
                      child: FilledButton.icon(
                        onPressed: onShopNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          minimumSize: const Size(
                            0,
                            AppSizes.bannerButtonHeight,
                          ),
                          shape: const StadiumBorder(),
                          elevation: 1,
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (banner?.imageUrl == null)
                    const ImageSlot(
                      asset: AppImages.homeWholesaleBanner,
                      placeholderIcons: [Icons.inventory_2_outlined],
                    )
                  else
                    AppNetworkImage(
                      url: banner!.imageUrl,
                      fallbackAsset: AppImages.homeWholesaleBanner,
                      placeholderIcon: Icons.inventory_2_outlined,
                      fit: BoxFit.cover,
                    ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: AppSpacing.lg,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.goldLight,
                            AppColors.goldLight.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
