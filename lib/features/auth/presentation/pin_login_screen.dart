import 'dart:async';

import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/data/auth_rules.dart';
import 'package:chimbo/features/auth/presentation/otp_screen.dart';
import 'package:chimbo/features/auth/presentation/widgets/auth_step_layout.dart';
import 'package:chimbo/features/auth/presentation/widgets/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What the phone screen hands to the PIN screen.
class PinLoginArgs {
  const PinLoginArgs({required this.phone, this.isLocked = false});

  /// `+255XXXXXXXXX`.
  final String phone;

  /// 5 wrong PINs: no pad, only "Umesahau PIN?".
  final bool isLocked;
}

/// "Ingia kwa PIN" for a registered number. On success the router opens Home by itself.
/// "Umesahau PIN?" sends an SMS code, then asks for a new PIN.
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key, required this.args});

  final PinLoginArgs args;

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _pin = '';
  String? _errorText;
  bool _isLoggingIn = false;
  bool _isSendingCode = false;

  bool get _isBusy => _isLoggingIn || _isSendingCode;

  Future<void> _logIn() async {
    setState(() {
      _isLoggingIn = true;
      _errorText = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .loginWithPin(phone: widget.args.phone, pin: _pin);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoggingIn = false;
        _pin = '';
        // "PIN si sahihi. Umebakiza majaribio N" comes ready from the server.
        _errorText = context.l10n.errorMessage(error);
      });
      // Too many wrong PINs: the only way in is a new PIN after an SMS code.
      if (error is ApiException && error.code == ApiErrorCode.pinLocked) {
        await _forgotPin();
      }
    }
  }

  /// "Umesahau PIN?": SMS code → OTP screen → Weka PIN Mpya.
  Future<void> _forgotPin() async {
    setState(() => _isSendingCode = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(widget.args.phone);
      if (!mounted) {
        return;
      }
      // Not awaited: after the code the router replaces these screens by itself.
      unawaited(
        context.push(
          AppRoutes.otp,
          extra: OtpScreenArgs(
            phone: widget.args.phone,
            resendAfter: result.resendAfter,
            debugCode: result.debugCode,
            isPinReset: true,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  void _changeNumber() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AuthStepLayout(
      onBack: _changeNumber,
      illustration: AppImages.authVerify,
      illustrationSlot: AppImageSlot.authVerify,
      illustrationIcons: const [Icons.lock_outline_rounded, Icons.dialpad],
      title: l10n.pinLoginTitle,
      subtitle: Column(
        children: [
          Text(l10n.pinLoginSubtitle),
          Text(TzPhone.format(widget.args.phone), style: textTheme.titleMedium),
        ],
      ),
      children: widget.args.isLocked
          ? [
              Text(
                l10n.pinLockedMessage,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.pinForgot,
                variant: AppButtonVariant.accent,
                isLoading: _isSendingCode,
                onPressed: _forgotPin,
              ),
            ]
          : [
              PinPad(
                pin: _pin,
                errorText: _errorText,
                enabled: !_isBusy,
                onChanged: (pin) => setState(() {
                  _pin = pin;
                  _errorText = null;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.actionLogin,
                variant: AppButtonVariant.accent,
                isLoading: _isLoggingIn,
                onPressed: AuthRules.isValidPin(_pin) && !_isBusy
                    ? _logIn
                    : null,
              ),
              TextButton(
                onPressed: _isBusy ? null : _forgotPin,
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: Text(l10n.pinForgot),
              ),
            ],
    );
  }
}
