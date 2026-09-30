import 'dart:async';

import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/phone_field.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/presentation/otp_screen.dart';
import 'package:chimbo/features/auth/presentation/widgets/auth_step_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Registration step 1 — "Karibu CHIMBO": the customer's phone number.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isSubmitting = false;
  String? _serverError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    return TzPhone.normalize(value ?? '') == null
        ? context.l10n.phoneInvalid
        : null;
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final phone = TzPhone.normalize(_phoneController.text)!;
    setState(() => _isSubmitting = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestOtp(phone);
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      // Not awaited: after a successful code the router replaces these screens by itself.
      unawaited(
        context.push(
          AppRoutes.otp,
          extra: OtpScreenArgs(
            phone: phone,
            resendAfter: result.resendAfter,
            debugCode: result.debugCode,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _serverError = context.l10n.errorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthStepLayout(
      step: 1,
      illustration: AppImages.authWelcome,
      illustrationIcons: const [Icons.storefront_outlined, Icons.phone_android],
      title: l10n.phoneTitle,
      subtitle: Text(l10n.phoneSubtitle),
      children: [
        Form(
          key: _formKey,
          child: PhoneField(
            controller: _phoneController,
            validator: _validatePhone,
            errorText: _serverError,
            enabled: !_isSubmitting,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.phoneHelper,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        // Orange as in the design (blueprint §6.3 would make it green).
        AppButton(
          label: l10n.actionContinue,
          variant: AppButtonVariant.accent,
          isLoading: _isSubmitting,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _TermsNotice(),
      ],
    );
  }
}

/// "Kwa kuendelea, unakubali **Masharti** na **Sera ya Faragha**."
class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const emphasis = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${l10n.termsNoticeStart} '),
          TextSpan(text: l10n.termsLink, style: emphasis),
          TextSpan(text: ' ${l10n.termsNoticeAnd} '),
          TextSpan(text: l10n.privacyLink, style: emphasis),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
