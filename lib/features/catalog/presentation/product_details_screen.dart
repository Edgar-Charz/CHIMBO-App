import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/quantity_stepper.dart';
import 'package:chimbo/features/cart/presentation/add_to_cart.dart';
import 'package:chimbo/features/catalog/application/catalog_providers.dart';
import 'package:chimbo/features/catalog/application/product_actions.dart';
import 'package:chimbo/features/catalog/data/models/product_details.dart';
import 'package:chimbo/features/catalog/data/product_links.dart';
import 'package:chimbo/features/catalog/data/tier_pricing.dart';
import 'package:chimbo/features/catalog/presentation/widgets/offer_widgets.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_gallery.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_info_strip.dart';
import 'package:chimbo/features/catalog/presentation/widgets/tier_table.dart';
import 'package:chimbo/features/support/application/support_providers.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:chimbo/features/wishlist/presentation/wishlist_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product page (design PDF p.6): photos, seller, MOQ/stock/delivery, tier ladder, quantity with
/// live savings, and the Uliza Muuzaji / Ongeza Kikapuni bar.
class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(productDetailsProvider(productId))
        .when(
          data: (details) => _ProductView(details: details),
          error: (error, _) => Scaffold(
            appBar: AppBar(),
            body: ErrorState(
              error: error,
              onRetry: () => ref.invalidate(productDetailsProvider(productId)),
            ),
          ),
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
        );
  }
}

class _ProductView extends ConsumerStatefulWidget {
  const _ProductView({required this.details});

  final ProductDetails details;

  @override
  ConsumerState<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<_ProductView> {
  late final TierPricing _pricing = TierPricing(widget.details.tiers);
  late int _quantity = _pricing.moq;
  bool _isAdding = false;

  Future<void> _addToCart() async {
    setState(() => _isAdding = true);
    await addToCart(
      context,
      ref,
      productId: widget.details.summary.id,
      quantity: _quantity,
    );
    if (mounted) {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _shareProduct() async {
    final product = widget.details.summary;
    final message =
        '${product.name} — ${Money.format(product.price)} kwenye CHIMBO\n'
        '${ProductLinks.webUrl(product)}';
    await ref.read(productShareProvider)(message);
  }

  Future<void> _askSeller(AsyncValue<SupportContacts> supportState) async {
    final toast = AppToast.of(context);
    final l10n = context.l10n;
    try {
      final contacts = switch (supportState) {
        AsyncData(:final value) => value,
        AsyncLoading() ||
        AsyncError() => await ref.refresh(supportContactsProvider.future),
      };
      final product = widget.details.summary;
      final message =
          'Habari CHIMBO, nina swali kuhusu ${product.name}: '
          '${ProductLinks.webUrl(product)}';
      final whatsappUrl = Uri.parse(contacts.whatsappUrl)
          .replace(queryParameters: {'text': message});
      final opened = await ref.read(externalUrlLauncherProvider)(whatsappUrl);
      if (!opened) {
        toast.error(l10n.helpCannotOpen);
      }
    } on Exception catch (error) {
      toast.error(l10n.errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = widget.details;
    final supportState = ref.watch(supportContactsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          WishlistButton(productId: widget.details.summary.id, onImage: false),
          IconButton(
            onPressed: _shareProduct,
            tooltip: l10n.actionShare,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        children: [
          ProductGallery(photos: details.photos),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NameAndSeller(details: details),
                if (details.summary.offer case final offer?) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      OfferLabel(percent: offer.percent),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: OfferCountdown(
                          endsAt: offer.endsAt,
                          showLabel: true,
                          // The server decides the new price: load the product again.
                          onEnded: () => ref.invalidate(
                            productDetailsProvider(details.summary.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                ProductInfoStrip(details: details),
                const SizedBox(height: AppSpacing.lg),
                TierTable(pricing: _pricing, quantity: _quantity),
                const SizedBox(height: AppSpacing.lg),
                _QuantityCard(
                  pricing: _pricing,
                  quantity: _quantity,
                  maxQuantity: details.stockQuantity,
                  onChanged: (quantity) => setState(() => _quantity = quantity),
                ),
                if (details.description case final description?) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.descriptionTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            spacing: AppSpacing.md,
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.actionAskSeller,
                  icon: Icons.chat_bubble_outline_rounded,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => _askSeller(supportState),
                ),
              ),
              Expanded(
                child: AppButton(
                  label: details.summary.isInStock
                      ? l10n.actionAddToCart
                      : l10n.actionOutOfStock,
                  icon: Icons.shopping_cart_outlined,
                  variant: AppButtonVariant.accent,
                  isLoading: _isAdding,
                  // Disabled (null) when sold out.
                  onPressed: details.summary.isInStock ? _addToCart : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameAndSeller extends StatelessWidget {
  const _NameAndSeller({required this.details});

  final ProductDetails details;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summary = details.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(summary.name, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              summary.sellerName,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (summary.isSellerVerified)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: AppSizes.iconSmall,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.verifiedSeller,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// "Kiasi [− 8 +]", then "Unaokoa TZS 4,000" and the next-tier hint.
class _QuantityCard extends StatelessWidget {
  const _QuantityCard({
    required this.pricing,
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final TierPricing pricing;
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final savings = pricing.savingsFor(quantity);
    final hint = pricing.nextTierHint(quantity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.quantityLabel, style: textTheme.titleSmall),
                ),
                QuantityStepper(
                  value: quantity,
                  min: pricing.moq,
                  max: maxQuantity,
                  onChanged: onChanged,
                ),
              ],
            ),
            if (savings > 0) ...[
              const Divider(height: AppSpacing.xl),
              _IconLine(
                icon: Icons.savings_outlined,
                color: AppColors.primary,
                text: l10n.savingsLabel(Money.format(savings)),
                style: textTheme.titleSmall,
              ),
            ],
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _IconLine(
                icon: Icons.trending_down_rounded,
                color: AppColors.accent,
                text: l10n.nextTierHint(
                  hint.extraQuantity,
                  Money.format(hint.tier.unitPrice),
                ),
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.color,
    required this.text,
    this.style,
  });

  final IconData icon;
  final Color color;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconMedium),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: style?.copyWith(color: color)),
        ),
      ],
    );
  }
}
