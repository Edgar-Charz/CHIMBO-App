import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/profile/application/profile_controller.dart';
import 'package:chimbo/features/profile/presentation/profile_photo_actions.dart';
import 'package:chimbo/features/profile/presentation/widgets/business_details_form.dart';
import 'package:chimbo/features/profile/presentation/widgets/profile_photo_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Hariri Wasifu" / "Taarifa za Biashara": the registration step 3 fields, pre-filled.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    BusinessProfileInput input,
  ) async {
    await ref.read(profileControllerProvider.notifier).save(input);
    if (context.mounted) {
      AppToast.of(context).success(context.l10n.profileSaved);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEdit)),
      body: profile.when(
        data: (value) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ProfilePhotoControl(
                  user: value.user,
                  showLabel: true,
                  onTap: () => changeProfilePhoto(
                    context,
                    ref,
                    hasPhoto: value.user.avatarUrl != null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BusinessDetailsForm(
                initial: value,
                submitLabel: l10n.actionSave,
                onSubmit: (input) => _save(context, ref, input),
              ),
            ],
          ),
        ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(profileControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
