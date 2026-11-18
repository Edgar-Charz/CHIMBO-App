import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/idempotency_key.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Collects the number that should receive the Selcom mobile-money prompt.
Future<void> showSelcomPaymentSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _SelcomPaymentSheet(order: order),
  );
}

class _SelcomPaymentSheet extends ConsumerStatefulWidget {
  const _SelcomPaymentSheet({required this.order});

  final Order order;

  @override
  ConsumerState<_SelcomPaymentSheet> createState() =>
      _SelcomPaymentSheetState();
}

class _SelcomPaymentSheetState extends ConsumerState<_SelcomPaymentSheet> {
  late final TextEditingController _phoneController = TextEditingController(
    text: TzPhone.format(ref.read(authControllerProvider).user?.phone ?? ''),
  );
  final String _idempotencyKey = newIdempotencyKey();
  bool _sending = false;
  String? _phoneError;
  String? _formError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final phone = TzPhone.normalize(_phoneController.text);
    setState(() {
      _phoneError = phone == null ? l10n.phoneInvalid : null;
      _formError = null;
    });
    if (phone == null) return;

    setState(() => _sending = true);
    try {
      final status = await ref
          .read(orderActionsProvider)
          .initiatePayment(
            orderId: widget.order.id,
            paymentMethodCode: widget.order.payment.method!.code,
            phoneNumber: phone,
            idempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;
      AppToast.of(context).success(l10n.selcomRequestSent);
      Navigator.of(context).pop();
      ref.invalidate(orderProvider(status.orderId));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _phoneError = error.fields.containsKey('phone_number')
            ? l10n.fieldErrorMessage(error, 'phone_number')
            : null;
        _formError = _phoneError == null ? l10n.errorMessage(error) : null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _sending = false;
          _formError = l10n.errorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.selcomSheetTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.selcomSheetMessage, style: textTheme.bodySmall),
              if (_formError case final error?) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  error,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.payerPhoneLabel,
                controller: _phoneController,
                errorText: _phoneError,
                enabled: !_sending,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.actionPayNow,
                variant: AppButtonVariant.accent,
                isLoading: _sending,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
