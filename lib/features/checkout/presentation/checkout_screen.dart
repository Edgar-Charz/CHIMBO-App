import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
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
        _ => const Center(child: CircularProgressIndicator()),
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
    final preview = ref.watch(checkoutPreviewProvider).value;
    final controller = ref.read(checkoutControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        CheckoutStepper(currentStep: choices.address == null ? 1 : 2),
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
            trailing: Text(Money.format(method.fee)),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.paymentMethodTitle, style: _sectionTitle(context)),
        const SizedBox(height: AppSpacing.sm),
        for (final method in options.paymentMethods)
          ChoiceTile(
            title: method.name,
            isSelected: method.code == choices.paymentMethod?.code,
            onTap: () => controller.selectPayment(method),
            leading: Icon(method.icon, color: AppColors.primary),
          ),
        if (preview != null) ...[
          const SizedBox(height: AppSpacing.md),
          TotalsCard(
            rows: [
              (label: l10n.summaryItemsTotal, amount: preview.subtotal),
              (label: l10n.summaryDelivery, amount: preview.deliveryFee),
            ],
            totalLabel: l10n.summaryAmountToPay,
            total: preview.total,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.actionContinueToReview,
          onPressed: choices.address == null || preview == null
              ? null
              : () => context.push(AppRoutes.checkoutReview),
        ),
      ],
    );
  }

  TextStyle? _sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;
}

/// Delivery method and payment method as read-only rows (Hakiki Oda).
class ChosenOptionRow extends StatelessWidget {
  const ChosenOptionRow({
    super.key,
    required this.title,
    required this.icon,
    required this.label,
    this.amount,
  });

  final String title;
  final IconData icon;
  final String label;
  final int? amount;

  @override
  Widget build(BuildContext context) {
    final price = amount;
    return SectionCard(
      title: title,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
          if (price != null) Text(Money.format(price)),
        ],
      ),
    );
  }
}
