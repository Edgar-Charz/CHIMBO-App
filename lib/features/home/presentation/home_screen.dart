import 'dart:async';

import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_logo.dart';
import 'package:chimbo/core/widgets/count_icon_badge.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:chimbo/features/home/data/home_data.dart';
import 'package:chimbo/features/home/presentation/widgets/greeting_card.dart';
import 'package:chimbo/features/home/presentation/widgets/home_order_attention.dart';
import 'package:chimbo/features/home/presentation/widgets/home_sections.dart';
import 'package:chimbo/features/home/presentation/widgets/product_rail.dart';
import 'package:chimbo/features/home/presentation/widgets/recently_ordered_rail.dart';
import 'package:chimbo/features/notifications/application/notifications_controller.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/profile/application/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Nyumbani (design PDF p.3): greeting + search, category cards, quick actions, banner, rails.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _greetingCardKey = GlobalKey();
  final GlobalKey _recentlyOrderedKey = GlobalKey();
  final GlobalKey _scrollViewportKey = GlobalKey();
  bool _showStickySearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateStickySearch);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateStickySearch)
      ..dispose();
    super.dispose();
  }

  void _updateStickySearch() {
    final greetingBox =
        _greetingCardKey.currentContext?.findRenderObject() as RenderBox?;
    final viewportBox =
        _scrollViewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (greetingBox == null || viewportBox == null || !greetingBox.hasSize) {
      return;
    }

    final greetingBottom =
        greetingBox.localToGlobal(Offset.zero).dy + greetingBox.size.height;
    final viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final shouldShow = greetingBottom <= viewportTop;
    if (shouldShow != _showStickySearch && mounted) {
      setState(() => _showStickySearch = shouldShow);
    }
  }

  void _openRecentlyOrdered() {
    final sectionContext = _recentlyOrderedKey.currentContext;
    if (sectionContext == null) {
      context.go(AppRoutes.orders);
      return;
    }

    unawaited(
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = ref.watch(
      authControllerProvider.select((state) => state.user?.fullName),
    );
    // The photo comes from the profile, so a new one shows here at once.
    final photoUrl = ref.watch(
      profileControllerProvider.select(
        (profile) => profile.value?.user.avatarUrl,
      ),
    );
    final home = ref.watch(homeDataProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Outside the list, so logo and bell stay put while Home scrolls under them.
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: _Header(),
            ),
            if (_showStickySearch)
              Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: HomeSearchBar(
                    onTap: () => context.go(AppRoutes.discover),
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  ref.invalidate(unreadNotificationsProvider);
                  ref.invalidate(ordersProvider(OrderGroup.active));
                  return ref.refresh(homeDataProvider.future);
                },
                child: ListView(
                  key: _scrollViewportKey,
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  children: [
                    GreetingCard(
                      key: _greetingCardKey,
                      fullName: fullName ?? '',
                      photoUrl: photoUrl,
                      now: DateTime.now(),
                      onSearchTap: () => context.go(AppRoutes.discover),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const HomeOrderAttention(),
                    home.when(
                      data: (data) => _HomeSections(
                        data: data,
                        recentlyOrderedKey: _recentlyOrderedKey,
                        onReorderTap: _openRecentlyOrdered,
                      ),
                      error: (error, _) => ErrorState(
                        error: error,
                        onRetry: () => ref.invalidate(homeDataProvider),
                      ),
                      loading: () => Skeletonizer(
                        child: _HomeSections(
                          data: _skeletonData,
                          onReorderTap: _openRecentlyOrdered,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shape-only stand-in drawn as grey blocks while Home loads.
const HomeData _skeletonData = HomeData(
  topCategories: [
    Category(id: 0, name: 'Cosmetics', tagline: 'Shamba la Vipodozi'),
    Category(id: 0, name: 'Jewelry', tagline: 'Mrembo Muuza Urembo'),
  ],
  banners: [HomeBanner(title: 'BEI ZA JUMLA')],
  bestSellers: [
    ProductCard.skeletonProduct,
    ProductCard.skeletonProduct,
    ProductCard.skeletonProduct,
  ],
  recentlyOrdered: [],
);

/// Logo on the left, notification bell (with the unread count) on the right.
class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsProvider).value ?? 0;
    return Row(
      children: [
        // Shrinks instead of overflowing on narrow screens or with large system text.
        const Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(fit: BoxFit.scaleDown, child: AppLogoInline()),
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          tooltip: context.l10n.notificationsTitle,
          icon: CountIconBadge(
            count: unread,
            icon: Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }
}

class _HomeSections extends StatelessWidget {
  const _HomeSections({
    required this.data,
    required this.onReorderTap,
    this.recentlyOrderedKey,
  });

  // Picture and colour per card position (cosmetics first, jewelry second, as in the design).
  static const List<({String image, IconData icon, Color background})>
  _categoryStyles = [
    (
      image: AppImages.homeCosmetics,
      icon: Icons.spa_outlined,
      background: AppColors.primaryLight,
    ),
    (
      image: AppImages.homeJewelry,
      icon: Icons.diamond_outlined,
      background: AppColors.goldLight,
    ),
  ];

  final HomeData data;
  final GlobalKey? recentlyOrderedKey;
  final VoidCallback onReorderTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = data.topCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.length == 1)
          _categoryCard(context, categories, 0)
        else
          for (var start = 0; start < categories.length; start += 2) ...[
            if (start > 0) const SizedBox(height: AppSpacing.md),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  for (
                    var index = start;
                    index < categories.length && index < start + 2;
                    index++
                  )
                    Expanded(child: _categoryCard(context, categories, index)),
                  if (categories.length.isOdd && start + 1 >= categories.length)
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ],
        const SizedBox(height: AppSpacing.lg),
        _QuickActions(onReorderTap: onReorderTap),
        const SizedBox(height: AppSpacing.lg),
        for (final banner in data.banners)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: WholesaleBanner(
              banner: banner,
              onShopNow: () => _openBannerTarget(context, banner),
            ),
          ),
        if (data.banners.isEmpty)
          WholesaleBanner(onShopNow: () => context.go(AppRoutes.discover)),
        if (data.offers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ProductRail(
            title: l10n.timedOffersTitle,
            products: data.offers,
            actionLabel: l10n.actionViewAll,
            onViewAll: () => context.go(
              AppRoutes.collection(ProductCollection.offers.apiValue),
            ),
          ),
        ],
        if (data.deals.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ProductRail(
            title: l10n.quickDeals,
            products: data.deals,
            actionLabel: l10n.actionViewAll,
            onViewAll: () => context.go(
              AppRoutes.collection(ProductCollection.deals.apiValue),
            ),
          ),
        ],
        if (data.newArrivals.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ProductRail(
            title: l10n.quickNewArrivals,
            products: data.newArrivals,
            actionLabel: l10n.actionViewAll,
            onViewAll: () => context.go(
              AppRoutes.collection(ProductCollection.newArrivals.apiValue),
            ),
          ),
        ],
        if (data.recentlyOrdered.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          RecentlyOrderedRail(
            key: recentlyOrderedKey,
            title: l10n.recentlyOrdered,
            products: data.recentlyOrdered,
            actionLabel: l10n.actionViewAll,
            onViewAll: () => context.go(AppRoutes.orders),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        ProductRail(
          title: l10n.quickBestSellers,
          products: data.bestSellers,
          actionLabel: l10n.actionViewAll,
          onViewAll: () => context.go(
            AppRoutes.collection(ProductCollection.bestSellers.apiValue),
          ),
        ),
      ],
    );
  }

  CategoryCard _categoryCard(
    BuildContext context,
    List<Category> categories,
    int index,
  ) {
    final category = categories[index];
    final style = _categoryStyles[index % _categoryStyles.length];
    return CategoryCard(
      category: category,
      image: style.image,
      imageUrl: category.imageUrl,
      placeholderIcon: style.icon,
      background: style.background,
      onBrowse: () => context.push(AppRoutes.category(category.id)),
    );
  }
}

void _openBannerTarget(BuildContext context, HomeBanner banner) {
  final value = banner.targetValue;
  switch (banner.targetType) {
    case 'category':
      final id = int.tryParse(value ?? '');
      if (id != null) context.push(AppRoutes.category(id));
      break;
    case 'product':
      final id = int.tryParse(value ?? '');
      if (id != null) context.push(AppRoutes.productDetails(id));
      break;
    case 'collection':
      final collection = ProductCollection.fromApi(value);
      if (collection != null) {
        context.go(AppRoutes.collection(collection.apiValue));
      }
      break;
    case 'url':
      final uri = Uri.tryParse(value ?? '');
      if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      break;
    default:
      context.go(AppRoutes.discover);
  }
}

/// Ofa · Bidhaa Mpya · Zinazouzwa Sana · Agiza Tena.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onReorderTap});

  final VoidCallback onReorderTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void openCollection(ProductCollection collection) =>
        context.go(AppRoutes.collection(collection.apiValue));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickAction(
          icon: Icons.local_fire_department_outlined,
          label: l10n.quickDeals,
          color: AppColors.danger,
          background: AppColors.accentLight,
          onTap: () => openCollection(ProductCollection.deals),
        ),
        QuickAction(
          icon: Icons.new_releases_outlined,
          label: l10n.quickNewArrivals,
          color: AppColors.info,
          background: AppColors.infoLight,
          onTap: () => openCollection(ProductCollection.newArrivals),
        ),
        QuickAction(
          icon: Icons.workspace_premium_outlined,
          label: l10n.quickBestSellers,
          color: AppColors.accent,
          background: AppColors.goldLight,
          onTap: () => openCollection(ProductCollection.bestSellers),
        ),
        QuickAction(
          icon: Icons.replay_rounded,
          label: l10n.quickReorder,
          color: AppColors.primary,
          background: AppColors.primaryLight,
          onTap: onReorderTap,
        ),
      ],
    );
  }
}
