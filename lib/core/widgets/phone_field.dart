import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tanzanian phone input: 🇹🇿 +255 prefix and the 9 local digits grouped as "712 345 678".
///
/// Only Tanzania is served, so the prefix is a label, not a country picker.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.errorText,
    this.validator,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [_TzPhoneInputFormatter()],
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: l10n.phoneHint,
        errorText: errorText,
        errorMaxLines: 2,
        prefixIcon: const _CountryPrefix(),
      ),
    );
  }
}

class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix();

  static const String _tanzaniaFlag = '🇹🇿';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              _tanzaniaFlag,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            TzPhone.countryCode,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: AppSpacing.md),
          const SizedBox(
            height: AppSizes.iconLarge / 2,
            child: VerticalDivider(color: AppColors.border),
          ),
        ],
      ),
    );
  }
}

/// Keeps only the 9 local digits (a typed leading 0 or pasted 255 is dropped) and groups them.
class _TzPhoneInputFormatter extends TextInputFormatter {
  static final RegExp _nonDigits = RegExp(r'\D');
  static const String _countryDigits = '255';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(_nonDigits, '');
    if (digits.length > TzPhone.localLength &&
        digits.startsWith(_countryDigits)) {
      digits = digits.substring(_countryDigits.length);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length > TzPhone.localLength) {
      digits = digits.substring(0, TzPhone.localLength);
    }
    final grouped = TzPhone.groupLocalDigits(digits);
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}
