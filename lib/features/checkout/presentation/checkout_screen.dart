import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/chimbo_loader.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/core/widgets/totals_card.dart';
import 'package:chimbo/features/addresses/application/addresses_controller.dart';
import 'package:chimbo/features/checkout/application/checkout_controller.dart';
import 'package:chimbo/features/checkout/data/models/checkout_options.dart';
import 'package:chimbo/features/checkout/presentation/widgets/address_section.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Malipo na Usafirishaji (design PDF p.7): address, delivery method, payment method, totals.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final options = ref.watch(checkoutOptionsProvider);
    final addresses = ref.watch(addressesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: switch ((options, addresses)) {
        (AsyncData(value: final loaded), AsyncData()) => _CheckoutForm(
          options: loaded,
        ),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => ErrorState(
          error: error,
          onRetry: () => ref
            ..invalidate(checkoutOptionsProvider)
            ..invalidate(addressesControllerProvider),
        ),
        _ => const ChimboLoader(),
      },
    );
  }
}

class _CheckoutForm extends ConsumerWidget {
  const _CheckoutForm({required this.options});

  final CheckoutOptions options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final choices = ref.watch(checkoutChoicesProvider);
    final paymentMethods =
        ref.watch(checkoutPaymentMethodsProvider) ?? const [];
    final previewState = ref.watch(checkoutPreviewProvider);
    final preview = previewState.value;
    final controller = ref.read(checkoutControllerProvider.notifier);
    final currentStep = choices.address == null
        ? 1
        : choices.deliveryMethod == null
        ? 2
        : 3;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              CheckoutStepper(currentStep: currentStep),
              const SizedBox(height: AppSpacing.lg),
              const AddressSection(),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.chooseDeliveryTitle, style: _sectionTitle(context)),
              const SizedBox(height: AppSpacing.sm),
              for (final method in options.deliveryMethods)
                ChoiceTile(
                  title: method.name,
                  isSelected: method.id == choices.deliveryMethod?.id,
                  onTap: () => controller.selectDelivery(method.id),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(method.feeLabel(l10n)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        method.eta(l10n),
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              if (_deliveryNote(context, choices.deliveryMethod)
                  case final note?)
                Text(note, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.paymentMethodTitle, style: _sectionTitle(context)),
              const SizedBox(height: AppSpacing.sm),
              for (final method in paymentMethods)
                ChoiceTile(
                  title: method.name,
                  isSelected: method.code == choices.paymentMethod?.code,
                  onTap: () => controller.selectPayment(method),
                  leading: PaymentMethodIconView(method: method),
                ),
              const SizedBox(height: AppSpacing.md),
              CheckoutPreviewSection(
                previewState: previewState,
                deliveryMethod: choices.deliveryMethod,
                itemsLabel: l10n.summaryItemsTotal,
                totalLabel: l10n.summaryAmountToPay,
                onRetry: () => ref.invalidate(checkoutPreviewProvider),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: AppButton(
                label: l10n.actionContinueToReview,
                onPressed:
                    choices.address == null ||
                        choices.deliveryMethod == null ||
                        choices.paymentMethod == null ||
                        preview == null ||
                        previewState.isLoading ||
                        previewState.hasError
                    ? null
                    : () => context.push(AppRoutes.checkoutReview),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle? _sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;

  /// Under the delivery options: how the chosen one's price works, or where to collect.
  String? _deliveryNote(BuildContext context, DeliveryMethod? method) {
    final l10n = context.l10n;
    final pickupPoint = options.pickupPoint;
    return switch (method) {
      DeliveryMethod(needsConfirmation: true) => l10n.deliveryEstimateNote,
      DeliveryMethod(isPaidToRider: true) => l10n.deliveryPaidToRiderNote,
      DeliveryMethod(isPickup: true) when pickupPoint != null =>
        '${pickupPoint.address} · ${pickupPoint.hours}',
      _ => null,
    };
  }
}

class CheckoutPreviewSection extends StatelessWidget {
  const CheckoutPreviewSection({
    super.key,
    required this.previewState,
    required this.deliveryMethod,
    required this.itemsLabel,
    required this.totalLabel,
    required this.onRetry,
  });

  final AsyncValue<CheckoutPreview?> previewState;
  final DeliveryMethod? deliveryMethod;
  final String itemsLabel;
  final String totalLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (previewState) {
      AsyncLoading() => const SizedBox(
        height: 56,
        child: ChimboLoader(compact: true, showMessage: false),
      ),
      AsyncError(:final error) => CheckoutInlineError(
        error: error,
        onRetry: onRetry,
      ),
      AsyncData(value: final preview?) => CheckoutTotalsCard(
        preview: preview,
        deliveryMethod: deliveryMethod,
        itemsLabel: itemsLabel,
        totalLabel: totalLabel,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class CheckoutInlineError extends StatelessWidget {
  const CheckoutInlineError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: AppSizes.iconMedium,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.errorMessage(error)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onRetry,
                      child: Text(l10n.actionRetry),
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

/// The server's totals at checkout. With upcountry transport the transport and the total are
/// labelled "(makadirio)", and a region without an estimate shows "Tutakujulisha".
class CheckoutTotalsCard extends StatelessWidget {
  const CheckoutTotalsCard({
    super.key,
    required this.preview,
    required this.deliveryMethod,
    required this.itemsLabel,
    required this.totalLabel,
  });

  final CheckoutPreview preview;
  final DeliveryMethod? deliveryMethod;
  final String itemsLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEstimate = preview.deliveryFeeNeedsConfirmation;
    final hasNoEstimate = isEstimate && deliveryMethod?.fee == null;
    // Bolt (paid to the rider) and pickup show words instead of an amount.
    final feeWords = deliveryMethod?.feeWords(l10n);
    return TotalsCard(
      rows: [
        (label: itemsLabel, amount: preview.subtotal),
        (
          label: isEstimate
              ? l10n.summaryTransportEstimate
              : l10n.summaryDelivery,
          amount: hasNoEstimate || feeWords != null
              ? null
              : preview.deliveryFee,
        ),
      ],
      totalLabel: isEstimate ? l10n.summaryTotalEstimate : totalLabel,
      total: preview.total,
      unknownAmountLabel: feeWords ?? l10n.summaryWeWillTellYou,
    );
  }
}

/// Delivery method and payment method as read-only rows (Hakiki Oda).
class ChosenOptionRow extends StatelessWidget {
  const ChosenOptionRow({
    super.key,
    required this.title,
    required this.icon,
    required this.label,
    this.priceLabel,
    this.leadingWidget,
    this.secondaryLabel,
  });

  final String title;
  final IconData icon;
  final Widget? leadingWidget;
  final String label;

  /// "TZS 5,000", "~TZS 15,000"…
  final String? priceLabel;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final price = priceLabel;
    return SectionCard(
      title: title,
      child: Row(
        children: [
          leadingWidget ?? Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                if (secondaryLabel case final secondary?)
                  Text(
                    secondary,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (price != null) Text(price),
        ],
      ),
    );
  }
}
