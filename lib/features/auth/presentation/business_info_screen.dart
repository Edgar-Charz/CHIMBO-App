import 'package:chimbo/core/assets/app_images.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/presentation/widgets/auth_step_layout.dart';
import 'package:chimbo/features/profile/presentation/widgets/business_details_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registration step 4 — "Tuambie Kuhusu Biashara Yako". On success the router opens Home.
class BusinessInfoScreen extends ConsumerWidget {
  const BusinessInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authController = ref.read(authControllerProvider.notifier);

    // Back from the last step means "start again with another number": the account has no
    // business details yet, so logging out is the only way back.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          authController.logout();
        }
      },
      child: AuthStepLayout(
        step: 4,
        onBack: authController.logout,
        illustration: AppImages.authBusiness,
        illustrationSlot: AppImageSlot.authBusiness,
        illustrationIcons: const [
          Icons.storefront_outlined,
          Icons.inventory_2_outlined,
        ],
        title: l10n.businessTitle,
        subtitle: Text(l10n.businessSubtitle),
        children: [
          BusinessDetailsForm(
            submitLabel: l10n.actionEnterChimbo,
            onSubmit: authController.completeProfile,
          ),
          const SizedBox(height: AppSpacing.md),
          const _EditLaterNote(),
        ],
      ),
    );
  }
}

/// Shield + "Unaweza kubadilisha taarifa hizi baadaye."
class _EditLaterNote extends StatelessWidget {
  const _EditLaterNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: AppSizes.iconMedium,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            context.l10n.businessEditLater,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
