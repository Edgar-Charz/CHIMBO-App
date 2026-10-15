import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The app's standard text input. Borders, colours and padding come from the theme.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.prefix,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.minHeight,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// Error from the server (e.g. `ApiException.fields['user_phone']`).
  final String? errorText;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefix,
        constraints: minHeight == null
            ? null
            : BoxConstraints(minHeight: minHeight!),
      ),
    );
  }
}
