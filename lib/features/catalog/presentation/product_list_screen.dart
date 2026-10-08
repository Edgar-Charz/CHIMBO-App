import 'dart:async';

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/count_icon_badge.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/application/product_list_controller.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';
import 'package:chimbo/features/catalog/presentation/widgets/catalog_labels.dart';
import 'package:chimbo/features/catalog/presentation/widgets/listing_controls.dart';
import 'package:chimbo/features/catalog/presentation/widgets/listing_sheets.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Category screens show curated sections; other listings use search, filters and a paginated
/// 2-column grid.
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.categoryId,
    this.collection,
    this.forceProductList = false,
  });

  final int? categoryId;
  final ProductCollection? collection;
  final bool forceProductList;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  /// Wait for a pause in typing before searching, so each key press isn't a request.
  static const Duration _searchDelay = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;

  ProductListScope get _scope =>
      (categoryId: widget.categoryId, collection: widget.collection);

  ProductQueryController get _queryController =>
      ref.read(productQueryProvider(_scope).notifier);

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDelay, () => _queryController.search(text));
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter < AppSizes.loadMoreThreshold) {
      ref.read(productListControllerProvider(_scope).notifier).loadMore();
    }
    return false;
  }

  Future<void> _openSort(ProductQuery query) async {
    final sort = await showSortSheet(context, query.sort);
    if (sort != null) {
      _queryController.sort(sort);
    }
  }

  Future<void> _openFilters(ProductQuery query, FilterSection section) async {
    final filters = await showFilterSheet(
      context,
      current: (
        minPrice: query.minPrice,
        maxPrice: query.maxPrice,
        maxMoq: query.maxMoq,
      ),
      section: section,
    );
    if (filters != null) {
      _queryController.filter(
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        maxMoq: filters.maxMoq,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(productQueryProvider(_scope));
    final category = _findCategory(ref.watch(categoriesProvider).value);
    final title =
        category?.name ?? widget.collection?.label(l10n) ?? l10n.navDiscover;
    // Chips: a category's sub-categories, or the top categories on Gundua.
    final chips =
        category?.children ??
        ref.watch(categoriesProvider).value ??
        const <Category>[];
    final showCategorySections =
        widget.categoryId != null &&
        widget.collection == null &&
        !widget.forceProductList;
    final categorySectionsScope = showCategorySections
        ? (
            categoryId: query.categoryId ?? widget.categoryId!,
            search: query.search,
            sort: query.sort,
            minPrice: query.minPrice,
            maxPrice: query.maxPrice,
            maxMoq: query.maxMoq,
          )
        : null;
    final categorySections = categorySectionsScope == null
        ? null
        : ref.watch(categoryProductSectionsProvider(categorySectionsScope));
    final products = ref.watch(productListControllerProvider(_scope));

    return Scaffold(
      appBar: AppBar(
        // Taller for a category: name, tagline and the verified line.
        toolbarHeight: category == null
            ? null
            : kToolbarHeight + AppSizes.categoryHeaderExtra,
        title: _Title(title: title, subtitle: category?.tagline),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.cart),
            tooltip: l10n.navCart,
            icon: CountIconBadge(count: ref.watch(cartCountProvider)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Keep search reachable while category chips, filters and products scroll.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: CatalogSearchField(
              controller: _searchController,
              hint: category == null
                  ? l10n.searchProductsHint
                  : l10n.searchInCategoryHint(category.name),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: RefreshIndicator(
                onRefresh: () async {
                  if (categorySectionsScope != null) {
                    ref.invalidate(
                      categoryProductSectionsProvider(categorySectionsScope),
                    );
                    await ref.read(
                      categoryProductSectionsProvider(categorySectionsScope)
                          .future,
                    );
                  }
                  ref.invalidate(productListControllerProvider(_scope));
                  await ref.read(productListControllerProvider(_scope).future);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        0,
                      ),
                      sliver: SliverList.list(
                        children: [
                          if (widget.collection != null) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InputChip(
                                avatar: const Icon(Icons.filter_list_rounded),
                                label: Text(widget.collection!.label(l10n)),
                                onDeleted: () {
                                  if (widget.categoryId != null) {
                                    context.go(
                                      AppRoutes.category(widget.categoryId!),
                                    );
                                  } else {
                                    context.go(AppRoutes.discover);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (chips.isNotEmpty) ...[
                            CategoryChips(
                              categories: chips,
                              selectedId: query.categoryId == widget.categoryId
                                  ? null
                                  : query.categoryId,
                              onSelected: _queryController.selectCategory,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          FilterBar(
                            hasFilters: query.hasFilters,
                            hasPriceFilter:
                                query.minPrice != null ||
                                query.maxPrice != null,
                            hasMoqFilter: query.maxMoq != null,
                            onFilter: () =>
                                _openFilters(query, FilterSection.all),
                            onSort: () => _openSort(query),
                            onPrice: () =>
                                _openFilters(query, FilterSection.price),
                            onMoq: () => _openFilters(query, FilterSection.moq),
                          ),
                        ],
                      ),
                    ),
                    if (showCategorySections) ...[
                      ...categorySections!.when(
                        data: (sections) => [
                          if (sections.newArrivals.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _CategoryProductSection(
                                title: l10n.quickNewArrivals,
                                products: sections.newArrivals,
                                onViewAll: () => context.go(
                                  AppRoutes.categoryListing(
                                    query.categoryId ?? widget.categoryId!,
                                    collection:
                                        ProductCollection.newArrivals.apiValue,
                                  ),
                                ),
                              ),
                            ),
                          if (sections.bestSellers.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _CategoryProductSection(
                                title: l10n.quickBestSellers,
                                products: sections.bestSellers,
                                onViewAll: () => context.go(
                                  AppRoutes.categoryListing(
                                    query.categoryId ?? widget.categoryId!,
                                    collection:
                                        ProductCollection.bestSellers.apiValue,
                                  ),
                                ),
                              ),
                            ),
                          if (sections.trending.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _CategoryProductSection(
                                title: l10n.trendingNow,
                                products: sections.trending,
                                onViewAll: () => context.go(
                                  AppRoutes.categoryListing(
                                    query.categoryId ?? widget.categoryId!,
                                  ),
                                ),
                              ),
                            ),
                          if (sections.deals.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _CategoryProductSection(
                                title: l10n.quickDeals,
                                products: sections.deals,
                                onViewAll: () => context.go(
                                  AppRoutes.categoryListing(
                                    query.categoryId ?? widget.categoryId!,
                                    collection:
                                        ProductCollection.deals.apiValue,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        error: (error, _) => [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: ErrorState(
                                error: error,
                                onRetry: () => ref.invalidate(
                                  categoryProductSectionsProvider(
                                    categorySectionsScope!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        loading: () => [
                          const SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            sliver: SliverProductGrid.skeleton(),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.sm,
                            AppSpacing.lg,
                            0,
                          ),
                          child: SectionHeader(title: l10n.allProducts),
                        ),
                      ),
                    ],
                    ...products.when(
                      data: (state) => [
                        if (state.items.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyState(
                              icon: Icons.search_off_rounded,
                              title: l10n.productsEmptyTitle,
                              message: l10n.productsEmptyMessage,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.md,
                              AppSpacing.lg,
                              0,
                            ),
                            sliver: SliverProductGrid(products: state.items),
                          ),
                        if (state.isLoadingMore)
                          const SliverToBoxAdapter(child: _LoadingMore()),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xl),
                        ),
                      ],
                      error: (error, _) => [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: ErrorState(
                            error: error,
                            onRetry: () => ref.invalidate(
                              productListControllerProvider(_scope),
                            ),
                          ),
                        ),
                      ],
                      loading: () => [
                        const SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          sliver: SliverProductGrid.skeleton(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Category? _findCategory(List<Category>? categories) {
    final categoryId = widget.categoryId;
    if (categoryId == null || categories == null) {
      return null;
    }
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }
}

/// "Cosmetics", "Shamba la Vipodozi" under it and, for a category, the verified-seller line
/// (the product cards show only the tick).
class _Title extends StatelessWidget {
  const _Title({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = subtitle;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        if (text != null) ...[
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: AppSizes.iconSmall,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  context.l10n.verifiedSeller,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryProductSection extends StatelessWidget {
  const _CategoryProductSection({
    required this.title,
    required this.products,
    required this.onViewAll,
  });

  final String title;
  final List<ProductSummary> products;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SectionHeader(
              title: title,
              actionLabel: context.l10n.actionViewAll,
              onAction: onViewAll,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  for (final product in products)
                    SizedBox(
                      width: AppSizes.railCardWidth,
                      child: ProductCard(product: product),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingMore extends StatelessWidget {
  const _LoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
