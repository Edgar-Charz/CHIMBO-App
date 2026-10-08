import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/checkout/data/models/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A payment method's "pay to" details: the number with a copy button, the account name, the bank
/// and the instructions. Used in an unpaid order's pay-to box and in "Malipo yangu".
class PaymentMethodDetails extends StatelessWidget {
  const PaymentMethodDetails({super.key, required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (method.accountNumber case final number?)
          CopyValueRow(
            label: method.type == PaymentMethodType.bank
                ? l10n.payToBankAccount
                : l10n.payToNumber,
            value: number,
          ),
        if (method.accountName case final name?)
          _InfoRow(label: l10n.payToAccountName, value: name),
        if (method.bankName case final bank?)
          _InfoRow(label: l10n.payToBank, value: bank),
        if (method.instructions case final instructions?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(instructions, style: textTheme.bodyMedium),
        ],
      ],
    );
  }
}

/// A value the customer types into their phone's payment menu, with a copy button.
class CopyValueRow extends StatelessWidget {
  const CopyValueRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  Future<void> _copy(BuildContext context) async {
    final toast = AppToast.of(context);
    final message = context.l10n.copiedMessage;
    await Clipboard.setData(ClipboardData(text: value));
    toast.success(message);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodySmall),
              SelectableText(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _copy(context),
          tooltip: context.l10n.actionCopy,
          icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: textTheme.bodySmall)),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
