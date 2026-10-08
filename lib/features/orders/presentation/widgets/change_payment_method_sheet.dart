import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/checkout/application/checkout_controller.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/checkout/presentation/widgets/checkout_widgets.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Badilisha njia ya malipo": every method switched on, the order's current one marked.
/// Choosing another changes it at once; "Lipa ukipokea" also confirms the order.
Future<void> showChangePaymentMethodSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ChangePaymentMethodSheet(order: order),
  );
}

class _ChangePaymentMethodSheet extends ConsumerStatefulWidget {
  const _ChangePaymentMethodSheet({required this.order});

  final Order order;

  @override
  ConsumerState<_ChangePaymentMethodSheet> createState() =>
      _ChangePaymentMethodSheetState();
}

class _ChangePaymentMethodSheetState
    extends ConsumerState<_ChangePaymentMethodSheet> {
  /// The method being sent, so its row shows a spinner and the others wait.
  String? _changingTo;
  String? _errorText;

  String? get _currentCode => widget.order.payment.method?.code;

  Future<void> _choose(PaymentMethod method) async {
    if (method.code == _currentCode || _changingTo != null) {
      return;
    }
    final l10n = context.l10n;
    final toast = AppToast.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _changingTo = method.code;
      _errorText = null;
    });
    try {
      await ref
          .read(orderActionsProvider)
          .changePaymentMethod(widget.order.id, method.code);
      toast.success(
        method.isCashOnDelivery
            ? l10n.paymentMethodChangedToCash
            : l10n.paymentMethodChanged(method.name),
      );
      navigator.pop();
    } catch (error) {
      // E.g. cash above the limit, already under review, time over: the server's message.
      if (mounted) {
        setState(() {
          _changingTo = null;
          _errorText = l10n.errorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final methods = ref.watch(paymentMethodsProvider);
    final errorText = _errorText;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.changePaymentMethodTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.changePaymentMethodMessage, style: textTheme.bodySmall),
              if (errorText != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  errorText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              ...methods.when(
                data: (list) => [
                  for (final method in list)
                    ChoiceTile(
                      title: method.name,
                      isSelected: method.code == _currentCode,
                      onTap: () => _choose(method),
                      leading: Icon(method.icon, color: AppColors.primary),
                      trailing: method.code == _changingTo
                          ? const SizedBox.square(
                              dimension: AppSizes.buttonProgress,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                ],
                error: (error, _) => [
                  ErrorState(
                    error: error,
                    onRetry: () => ref.invalidate(paymentMethodsProvider),
                  ),
                ],
                loading: () => [
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
