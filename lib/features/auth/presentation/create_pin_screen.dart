import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/presentation/widgets/auth_step_layout.dart';
import 'package:chimbo/features/auth/presentation/widgets/pin_setup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Tengeneza PIN" (registration step 3, and accounts made before PIN login) or "Weka PIN
/// Mpya" after "Umesahau PIN?". On success the router moves on by itself (business details or
/// Home).
class CreatePinScreen extends ConsumerWidget {
  const CreatePinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authController = ref.read(authControllerProvider.notifier);
    final isPinReset = ref.watch(
      authControllerProvider.select((state) => state.isPinReset),
    );

    // Back means "start again with another number"; without a PIN there is no other way back.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          authController.logout();
        }
      },
      child: AuthStepLayout(
        step: isPinReset ? null : 3,
        onBack: authController.logout,
        illustration: AppImages.authVerify,
        illustrationSlot: AppImageSlot.authVerify,
        illustrationIcons: const [Icons.lock_outline_rounded, Icons.dialpad],
        title: isPinReset ? l10n.resetPinTitle : l10n.createPinTitle,
        subtitle: Text(l10n.createPinSubtitle),
        children: [
          PinSetupForm(
            submitLabel: l10n.actionSavePin,
            onSubmit: authController.savePin,
          ),
        ],
      ),
    );
  }
}
