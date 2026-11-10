import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/chimbo_loader.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/checkout/application/checkout_controller.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
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
    final previewState = ref.read(checkoutPreviewProvider);
    final preview = previewState.value;
    final cartState = ref.read(cartControllerProvider);
    final cart = cartState.value;
    final optionsState = ref.read(checkoutOptionsProvider);
    final options = optionsState.value;
    final address = choices.address;
    final deliveryMethod = choices.deliveryMethod;
    final paymentMethod = choices.paymentMethod;
    if (address == null ||
        deliveryMethod == null ||
        paymentMethod == null ||
        preview == null ||
        previewState.isLoading ||
        previewState.hasError ||
        cartState.isLoading ||
        cartState.hasError ||
        cart == null ||
        cart.isEmpty ||
        (deliveryMethod.isPickup &&
            (optionsState.isLoading ||
                optionsState.hasError ||
                !_hasPickupDetails(options?.pickupPoint)))) {
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
    final previewState = ref.watch(checkoutPreviewProvider);
    final cartState = ref.watch(cartControllerProvider);
    final cart = cartState.value;
    final optionsState = ref.watch(checkoutOptionsProvider);
    final pickupPoint = optionsState.value?.pickupPoint;
    final deliveryMethod = choices.deliveryMethod;
    final paymentMethod = choices.paymentMethod;
    final canConfirm =
        choices.address != null &&
        deliveryMethod != null &&
        paymentMethod != null &&
        previewState.value != null &&
        !previewState.isLoading &&
        !previewState.hasError &&
        !cartState.isLoading &&
        !cartState.hasError &&
        cart != null &&
        !cart.isEmpty &&
        (!deliveryMethod.isPickup ||
            (!optionsState.isLoading &&
                !optionsState.hasError &&
                _hasPickupDetails(pickupPoint)));

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
              secondaryLabel: deliveryMethod.eta(l10n),
            ),
          ],
          if (deliveryMethod?.isPickup ?? false) ...[
            const SizedBox(height: AppSpacing.md),
            _PickupReviewSection(
              pickupPoint: pickupPoint,
              isLoading: optionsState.isLoading,
              error: optionsState.error,
              onRetry: () => ref.invalidate(checkoutOptionsProvider),
            ),
          ],
          if (paymentMethod != null) ...[
            const SizedBox(height: AppSpacing.md),
            ChosenOptionRow(
              title: l10n.paymentMethodTitle,
              icon: paymentMethod.icon,
              leadingWidget: PaymentMethodIconView(method: paymentMethod),
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
            child: switch (cartState) {
              AsyncData(value: final value) when !value.isEmpty => Column(
                children: [
                  for (final (index, line) in value.lines.indexed) ...[
                    if (index > 0) const Divider(height: AppSpacing.lg),
                    CheckoutOrderLine(line: line),
                  ],
                ],
              ),
              AsyncData() => Text(l10n.cartEmptyMessage),
              AsyncError(:final error) => CheckoutInlineError(
                error: error,
                onRetry: () => ref.invalidate(cartControllerProvider),
              ),
              _ => const SizedBox(
                height: 56,
                child: ChimboLoader(compact: true, showMessage: false),
              ),
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CheckoutPreviewSection(
            previewState: previewState,
            deliveryMethod: deliveryMethod,
            itemsLabel: l10n.summaryItems(previewState.value?.lineCount ?? 0),
            totalLabel: l10n.summaryTotal,
            onRetry: () => ref.invalidate(checkoutPreviewProvider),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.actionConfirmOrder,
            isLoading: _isPlacing,
            onPressed: canConfirm ? _confirm : null,
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

bool _hasPickupDetails(PickupPoint? pickupPoint) =>
    pickupPoint != null &&
    pickupPoint.address.trim().isNotEmpty &&
    pickupPoint.hours.trim().isNotEmpty;

class _PickupReviewSection extends StatelessWidget {
  const _PickupReviewSection({
    required this.pickupPoint,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final PickupPoint? pickupPoint;
  final bool isLoading;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final point = pickupPoint;
    if (isLoading) {
      return const SizedBox(height: 56, child: ChimboLoader(compact: true));
    }
    if (error case final loadError?) {
      return CheckoutInlineError(error: loadError, onRetry: onRetry);
    }
    if (!_hasPickupDetails(point)) {
      return SectionCard(
        title: l10n.pickupPointTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pickupPointUnavailable),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: Text(l10n.actionRetry),
              ),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      title: l10n.pickupPointTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point!.address, style: Theme.of(context).textTheme.titleSmall),
          Text(
            point.hours,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
