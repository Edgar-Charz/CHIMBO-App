import 'dart:async';

import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/exit_guard.dart';
import 'package:chimbo/core/widgets/phone_field.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/data/models/login_start.dart';
import 'package:chimbo/features/auth/presentation/otp_screen.dart';
import 'package:chimbo/features/auth/presentation/pin_login_screen.dart';
import 'package:chimbo/features/auth/presentation/widgets/auth_step_layout.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Karibu CHIMBO": the phone number, for everyone. The server says what comes next: the PIN
/// (registered), or an SMS code (new number, or no PIN yet) — registration step 1.
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
      final start = await ref
          .read(authControllerProvider.notifier)
          .startLogin(phone);
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      // Not awaited: after a successful login the router replaces these screens by itself.
      unawaited(_openNextStep(start));
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _serverError = context.l10n.errorMessage(error);
        });
      }
    }
  }

  Future<void> _openNextStep(LoginStart start) {
    return switch (start.nextStep) {
      LoginNextStep.otp => context.push(
        AppRoutes.otp,
        extra: OtpScreenArgs(
          phone: start.phone,
          resendAfter: start.otp!.resendAfter,
          debugCode: start.otp!.debugCode,
        ),
      ),
      LoginNextStep.pin || LoginNextStep.pinLocked => context.push(
        AppRoutes.pinLogin,
        extra: PinLoginArgs(
          phone: start.phone,
          isLocked: start.nextStep == LoginNextStep.pinLocked,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wasSignedOut = ref.watch(
      authControllerProvider.select((state) => state.wasSignedOut),
    );
    // The first screen after logging out: one back mustn't close the app.
    return ExitGuard(
      child: AuthStepLayout(
        step: 1,
        illustration: AppImages.authWelcome,
        illustrationSlot: AppImageSlot.authWelcome,
        illustrationIcons: const [
          Icons.storefront_outlined,
          Icons.phone_android,
        ],
        title: l10n.phoneTitle,
        subtitle: Text(l10n.phoneSubtitle),
        children: [
          if (wasSignedOut) ...[
            Text(
              l10n.signedOutNotice,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
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
      ),
    );
  }
}

/// "Kwa kuendelea, unakubali **Masharti** na **Sera ya Faragha**." — both links open the page.
class _TermsNotice extends StatefulWidget {
  const _TermsNotice();

  @override
  State<_TermsNotice> createState() => _TermsNoticeState();
}

class _TermsNoticeState extends State<_TermsNotice> {
  // Tap handlers for the two links inside the sentence; they must be disposed with the widget.
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _open(LegalPageType.terms);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _open(LegalPageType.privacy);

  void _open(LegalPageType type) => context.push(AppRoutes.legalPage(type));

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const emphasis = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${l10n.termsNoticeStart} '),
          TextSpan(
            text: l10n.termsLink,
            style: emphasis,
            recognizer: _termsTap,
          ),
          TextSpan(text: ' ${l10n.termsNoticeAnd} '),
          TextSpan(
            text: l10n.privacyLink,
            style: emphasis,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
