import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/features/auth/data/auth_rules.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';
import 'package:chimbo/features/auth/presentation/widgets/pin_pad.dart';
import 'package:flutter/material.dart';

enum _PinStep { current, create, confirm }

/// Choosing a PIN one step at a time on the [PinPad]: the current PIN (only when
/// [askCurrentPin], for "Badilisha PIN"), the new PIN, then the same again.
///
/// [onSubmit] sends it; an `ApiException` it throws is shown on the step it is about
/// (`current_pin`, `user_pin` — e.g. an easy PIN — or `user_pin_confirmation`).
class PinSetupForm extends StatefulWidget {
  const PinSetupForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.askCurrentPin = false,
  });

  final String submitLabel;
  final Future<void> Function(PinInput input) onSubmit;
  final bool askCurrentPin;

  @override
  State<PinSetupForm> createState() => _PinSetupFormState();
}

class _PinSetupFormState extends State<PinSetupForm> {
  late _PinStep _step = widget.askCurrentPin
      ? _PinStep.current
      : _PinStep.create;
  final Map<_PinStep, String> _values = {
    for (final step in _PinStep.values) step: '',
  };
  String? _errorText;
  bool _isSubmitting = false;

  String get _value => _values[_step]!;

  void _onChanged(String value) => setState(() {
    _values[_step] = value;
    _errorText = null;
  });

  /// Back to [step] with its value (and every later one) cleared, showing [error].
  void _restartAt(_PinStep step, String? error) => setState(() {
    for (final later in _PinStep.values.where((s) => s.index >= step.index)) {
      _values[later] = '';
    }
    _step = step;
    _errorText = error;
  });

  Future<void> _next() async {
    final l10n = context.l10n;
    if (!AuthRules.isValidPin(_value)) {
      setState(() => _errorText = l10n.pinWrongLength);
      return;
    }
    switch (_step) {
      case _PinStep.current:
        setState(() => _step = _PinStep.create);
      case _PinStep.create:
        setState(() => _step = _PinStep.confirm);
      case _PinStep.confirm:
        if (_value != _values[_PinStep.create]) {
          _restartAt(_PinStep.confirm, l10n.pinMismatch);
          return;
        }
        await _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        PinInput(
          pin: _values[_PinStep.create]!,
          confirmation: _values[_PinStep.confirm]!,
          currentPin: widget.askCurrentPin ? _values[_PinStep.current] : null,
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        _showError(error);
      }
    } catch (error) {
      // Not an API answer: a general message instead of an uncaught error.
      if (mounted) {
        setState(() => _errorText = context.l10n.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(ApiException error) {
    final fields = error.fields;
    final message = context.l10n.errorMessage(error);
    if (fields['current_pin'] case final field?) {
      _restartAt(_PinStep.current, field);
    } else if (fields['user_pin'] case final field?) {
      _restartAt(_PinStep.create, field);
    } else if (fields['user_pin_confirmation'] case final field?) {
      _restartAt(_PinStep.confirm, field);
    } else if (widget.askCurrentPin &&
        (error.code == ApiErrorCode.pinInvalid ||
            error.code == ApiErrorCode.pinLocked)) {
      // A wrong current PIN ("Umebakiza majaribio N").
      _restartAt(_PinStep.current, message);
    } else {
      setState(() => _errorText = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompt = switch (_step) {
      _PinStep.current => l10n.pinStepCurrent,
      _PinStep.create => l10n.pinStepNew,
      _PinStep.confirm => l10n.pinStepConfirm,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        PinPad(
          pin: _value,
          errorText: _errorText,
          enabled: !_isSubmitting,
          onChanged: _onChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: _step == _PinStep.confirm
              ? widget.submitLabel
              : l10n.actionContinue,
          variant: AppButtonVariant.accent,
          isLoading: _isSubmitting,
          onPressed: _value.length >= AuthRules.pinMinLength ? _next : null,
        ),
        if (_step == _PinStep.confirm)
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => _restartAt(_PinStep.create, null),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(l10n.pinStartOver),
          ),
      ],
    );
  }
}
