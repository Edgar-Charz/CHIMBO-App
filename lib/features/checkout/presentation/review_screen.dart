import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:chimbo/features/checkout/application/checkout_controller.dart';
import 'package:chimbo/features/checkout/presentation/checkout_screen.dart';
import 'package:chimbo/features/checkout/presentation/widgets/address_section.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hakiki Oda (design PDF p.8): everything chosen, the server's totals, and Thibitisha Oda.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _isPlacing = false;

  Future<void> _confirm() async {
    final choices = ref.read(checkoutChoicesProvider);
    final preview = ref.read(checkoutPreviewProvider).value;
    final address = choices.address;
    final deliveryMethod = choices.deliveryMethod;
    final paymentMethod = choices.paymentMethod;
    if (address == null ||
        deliveryMethod == null ||
        paymentMethod == null ||
        preview == null) {
      return;
    }
    setState(() => _isPlacing = true);
    try {
      final order = await ref
          .read(checkoutControllerProvider.notifier)
          .placeOrder(
            address: address,
            deliveryMethod: deliveryMethod,
            paymentMethod: paymentMethod,
            expectedTotal: preview.total,
          );
      if (mounted) {
        context.go(AppRoutes.orderSuccess(order.id));
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      // Prices may have moved: show the new totals before trying again.
      ref.invalidate(checkoutPreviewProvider);
      AppToast.of(context).error(context.l10n.errorMessage(error));
    } catch (error) {
      if (mounted) {
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final choices = ref.watch(checkoutChoicesProvider);
    final preview = ref.watch(checkoutPreviewProvider).value;
    final cart = ref.watch(cartControllerProvider).value;
    final deliveryMethod = choices.deliveryMethod;
    final paymentMethod = choices.paymentMethod;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const CheckoutStepper(currentStep: 4),
          const SizedBox(height: AppSpacing.lg),
          const AddressSection(),
          if (deliveryMethod != null) ...[
            const SizedBox(height: AppSpacing.md),
            ChosenOptionRow(
              title: l10n.deliveryMethodTitle,
              icon: Icons.local_shipping_outlined,
              label: deliveryMethod.name,
              priceLabel: deliveryMethod.feeLabel(l10n),
            ),
          ],
          if (paymentMethod != null) ...[
            const SizedBox(height: AppSpacing.md),
            ChosenOptionRow(
              title: l10n.paymentMethodTitle,
              icon: paymentMethod.icon,
              label: paymentMethod.name,
            ),
            // Mobile money / bank: where to pay is shown once the order exists (upcountry: once
            // staff have confirmed the transport price).
            if (!paymentMethod.isCashOnDelivery) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                deliveryMethod?.needsConfirmation ?? false
                    ? l10n.transportPayLaterHint
                    : l10n.payAfterOrderingHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: l10n.orderSummaryTitle,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final line in cart?.lines ?? const <CartLine>[])
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    child: SizedBox.square(
                      dimension: AppSizes.orderThumbnail,
                      child: AppNetworkImage(
                        url: line.product.imageUrl,
                        placeholderIcon: ProductCard.placeholderIcon,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: AppSpacing.md),
            CheckoutTotalsCard(
              preview: preview,
              deliveryMethod: deliveryMethod,
              itemsLabel: l10n.summaryItems(preview.lineCount),
              totalLabel: l10n.summaryTotal,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.actionConfirmOrder,
            isLoading: _isPlacing,
            onPressed: choices.address == null || preview == null
                ? null
                : _confirm,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: AppSizes.iconMedium,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.paymentSecure,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
