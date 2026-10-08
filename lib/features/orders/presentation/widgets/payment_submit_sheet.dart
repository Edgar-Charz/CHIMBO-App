import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/data/models/order_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Nimelipa": the number (or bank account) the money came from and the SMS confirmation code.
/// Closes after sending; the order then shows "Tunakagua malipo yako".
Future<void> showPaymentSubmitSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // Room for the keyboard under the fields.
    isScrollControlled: true,
    builder: (context) => _PaymentSubmitSheet(order: order),
  );
}

class _PaymentSubmitSheet extends ConsumerStatefulWidget {
  const _PaymentSubmitSheet({required this.order});

  final Order order;

  @override
  ConsumerState<_PaymentSubmitSheet> createState() =>
      _PaymentSubmitSheetState();
}

class _PaymentSubmitSheetState extends ConsumerState<_PaymentSubmitSheet> {
  late final TextEditingController _payerController = TextEditingController(
    text: _isBank ? '' : _customerPhone,
  );
  final TextEditingController _referenceController = TextEditingController();
  bool _isSending = false;
  String? _payerError;
  String? _referenceError;
  String? _formError;

  bool get _isBank =>
      widget.order.payment.method?.type == PaymentMethodType.bank;

  /// Mobile money usually comes from the customer's own number, so it is filled in.
  String get _customerPhone {
    final phone = ref.read(authControllerProvider).user?.phone;
    return phone == null ? '' : TzPhone.format(phone);
  }

  @override
  void dispose() {
    _payerController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final payer = _payerController.text.trim();
    final reference = _referenceController.text.trim();
    setState(() {
      _payerError = payer.isEmpty ? l10n.fieldRequired : null;
      _referenceError = reference.isEmpty ? l10n.fieldRequired : null;
      _formError = null;
    });
    if (_payerError != null || _referenceError != null) {
      return;
    }
    setState(() => _isSending = true);
    final toast = AppToast.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(orderActionsProvider)
          .submitPayment(
            widget.order.id,
            PaymentSubmission(payerAccount: payer, reference: reference),
          );
      toast.success(l10n.paymentSent);
      navigator.pop();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      // Field problems go under their field; anything else (already sent, time over …) on top.
      setState(() {
        _isSending = false;
        _payerError = error.fields['payment_payer_account'];
        _referenceError = error.fields['payment_reference'];
        _formError = _payerError == null && _referenceError == null
            ? l10n.errorMessage(error)
            : null;
      });
    } catch (error) {
      // Not an API answer (a bug or a device problem): stop the spinner and say so.
      if (mounted) {
        setState(() {
          _isSending = false;
          _formError = l10n.errorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final formError = _formError;
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
              Text(l10n.paymentSheetTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.paymentSheetMessage, style: textTheme.bodySmall),
              if (formError != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  formError,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: _isBank ? l10n.payerBankLabel : l10n.payerPhoneLabel,
                controller: _payerController,
                errorText: _payerError,
                enabled: !_isSending,
                keyboardType: _isBank
                    ? TextInputType.text
                    : TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.paymentReferenceLabel,
                hint: l10n.paymentReferenceHint,
                controller: _referenceController,
                errorText: _referenceError,
                enabled: !_isSending,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.actionSendPayment,
                variant: AppButtonVariant.accent,
                isLoading: _isSending,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
