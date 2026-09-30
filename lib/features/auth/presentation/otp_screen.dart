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
import 'package:chimbo/core/widgets/otp_input.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/data/auth_rules.dart';
import 'package:chimbo/features/auth/presentation/widgets/auth_step_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What the phone screen hands to the OTP screen.
class OtpScreenArgs {
  const OtpScreenArgs({
    required this.phone,
    required this.resendAfter,
    this.debugCode,
  });

  /// `+255XXXXXXXXX`.
  final String phone;
  final Duration resendAfter;

  /// Sent only by a test server in "show code" mode; filled in for the tester.
  final String? debugCode;
}

/// Registration step 2 — "Thibitisha Namba": the 6-digit code.
///
/// On success the router moves on by itself (step 3 for a new customer, Home for a returning one).
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});

  final OtpScreenArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const Duration _tick = Duration(seconds: 1);

  late String _code = widget.args.debugCode ?? '';

  /// The code a "show code" test server sent (replaced by "Tuma tena").
  late String? _debugCode = widget.args.debugCode;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;
  late DateTime _resendAvailableAt;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.args.resendAfter);
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  int get _secondsUntilResend {
    final left = _resendAvailableAt.difference(DateTime.now()).inSeconds;
    return left > 0 ? left : 0;
  }

  void _startCountdown(Duration resendAfter) {
    _countdown?.cancel();
    _resendAvailableAt = DateTime.now().add(resendAfter);
    _countdown = Timer.periodic(_tick, (timer) {
      if (_secondsUntilResend == 0) {
        timer.cancel();
      }
      setState(() {});
    });
  }

  Future<void> _verify() async {
    if (!AuthRules.isValidOtp(_code)) {
      setState(
        () => _errorText = context.l10n.otpIncomplete(AuthRules.otpLength),
      );
      return;
    }
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(phone: widget.args.phone, code: _code);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorText = context.l10n.errorMessage(error);
        });
      }
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(widget.args.phone);
      if (!mounted) {
        return;
      }
      _startCountdown(result.resendAfter);
      setState(() {
        _debugCode = result.debugCode;
        _code = result.debugCode ?? '';
      });
      AppToast.of(context).success(context.l10n.otpResent);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorText = context.l10n.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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
    return AuthStepLayout(
      step: 2,
      onBack: _changeNumber,
      illustration: AppImages.authVerify,
      illustrationIcons: const [Icons.shield_outlined, Icons.phonelink_lock],
      title: l10n.otpTitle,
      subtitle: _SentTo(phone: widget.args.phone),
      children: [
        OtpInput(
          // A new key when the test code changes, so the boxes show the new one.
          key: ValueKey(_debugCode),
          initialCode: _debugCode,
          length: AuthRules.otpLength,
          enabled: !_isVerifying,
          errorText: _errorText,
          onChanged: (code) => setState(() {
            _code = code;
            _errorText = null;
          }),
          onCompleted: (_) => _verify(),
        ),
        if (_debugCode case final code?) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.otpTestModeHint(code),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.actionVerify,
          variant: AppButtonVariant.accent,
          isLoading: _isVerifying,
          onPressed: _verify,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ResendRow(
          secondsLeft: _secondsUntilResend,
          isResending: _isResending,
          onResend: _resend,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.otpChangeNumber,
          variant: AppButtonVariant.outlined,
          onPressed: _isVerifying ? null : _changeNumber,
        ),
      ],
    );
  }
}

/// "Tumeweka namba ya uthibitisho kwenye" + the number in bold.
class _SentTo extends StatelessWidget {
  const _SentTo({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.l10n.otpSentTo),
        Text(
          TzPhone.format(phone),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

/// "Hukupokea namba? Tuma tena" — the link waits for the countdown.
class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.secondsLeft,
    required this.isResending,
    required this.onResend,
  });

  final int secondsLeft;
  final bool isResending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canResend = secondsLeft == 0 && !isResending;
    // Wrap, not Row: with large system text the link moves to a second line instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.otpNotReceived,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: canResend ? onResend : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(
            secondsLeft > 0 ? l10n.otpResendIn(secondsLeft) : l10n.otpResend,
          ),
        ),
      ],
    );
  }
}
