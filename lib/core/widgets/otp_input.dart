import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One box per digit of a login code.
///
/// A single invisible text field sits on top of the boxes and does the real typing, so paste,
/// SMS autofill and delete all behave like a normal field.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.initialCode,
  });

  final int length;

  /// Called once all boxes are filled.
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;

  /// Pre-filled code (test servers in "show code" mode). Give the widget a new key to replace it.
  final String? initialCode;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialCode,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Redraw the boxes when focus moves in or out (highlight on the next empty box).
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String code) {
    setState(() {});
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final errorText = widget.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var index = 0; index < widget.length; index++)
                  _DigitBox(
                    digit: index < code.length ? code[index] : '',
                    isActive:
                        _focusNode.hasFocus &&
                        index == code.length.clamp(0, widget.length - 1),
                    hasError: errorText != null,
                  ),
              ],
            ),
            Positioned.fill(child: _hiddenField(context)),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }

  Widget _hiddenField(BuildContext context) {
    return Semantics(
      label: context.l10n.otpFieldLabel(widget.length),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        autofocus: true,
        onChanged: _onChanged,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(widget.length),
        ],
        showCursor: false,
        enableInteractiveSelection: false,
        style: const TextStyle(color: Colors.transparent),
        decoration: const InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.danger
        : isActive
        ? AppColors.primary
        : AppColors.border;
    return Container(
      width: AppSizes.otpBoxWidth,
      height: AppSizes.otpBoxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: borderColor,
          width: isActive ? AppSizes.borderWidth * 2 : AppSizes.borderWidth,
        ),
      ),
      child: Text(digit, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
