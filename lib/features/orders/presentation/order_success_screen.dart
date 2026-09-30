import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/image_slot.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Oda Imepokelewa!" (design PDF p.8): a short check-mark celebration, the order number,
/// total and delivery estimate, then Fuatilia Oda or Rudi Nyumbani.
class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider(orderId));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.fullScreenSystemBars,
      child: Scaffold(
        body: SafeArea(
          child: order.when(
            data: (value) => _SuccessContent(order: value),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(orderProvider(orderId)),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class _SuccessContent extends ConsumerWidget {
  const _SuccessContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final fullName = ref.watch(
      authControllerProvider.select((state) => state.user?.fullName),
    );
    final firstName = (fullName ?? '').split(' ').first;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Center(child: _CheckBadge()),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.orderReceivedTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        Text(l10n.orderReceivedMessage(firstName), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Text(
                l10n.orderNumber(order.number),
                style: textTheme.titleMedium,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          color: AppColors.goldLight,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.summaryTotal)),
                  Text(Money.format(order.total), style: textTheme.titleLarge),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(l10n.infoDelivery)),
                  Text(order.deliveryMethod.eta(l10n)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AspectRatio(
          aspectRatio: 16 / 10,
          child: ImageSlot(
            asset: AppImages.orderSuccess,
            placeholderIcons: [Icons.inventory_2_outlined],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.actionTrackOrder,
          variant: AppButtonVariant.accent,
          onPressed: () => context.go(AppRoutes.orderDetails(order.id)),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.actionBackHome,
          variant: AppButtonVariant.outlined,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}

/// Green tick in a gold ring that pops in once.
class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  static const double _ringWidth = 6;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.slow,
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: AppSizes.successBadge,
        height: AppSizes.successBadge,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: _ringWidth),
        ),
        child: const Icon(
          Icons.check_rounded,
          size: AppSizes.iconLarge,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
