import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/person_avatar.dart';
import 'package:chimbo/core/widgets/verified_badge.dart';
import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:flutter/material.dart';

/// Top of Wasifu: photo (tap to change), name, phone, location, shop name and "Hariri Wasifu".
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onChangePhoto,
  });

  final Profile profile;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final business = profile.business;
    final location = [
      business?.districtName,
      business?.regionName,
    ].whereType<String>().join(', ');

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentLight, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                _EditablePhoto(user: profile.user, onTap: onChangePhoto),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.user.fullName ?? '',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        TzPhone.format(profile.user.phone),
                        style: textTheme.bodyMedium,
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _IconLine(
                          icon: Icons.location_on_outlined,
                          text: location,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        business?.businessName ?? l10n.profileBusinessOwner,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (business?.isVerified ?? false) ...[
                        const SizedBox(height: AppSpacing.xs),
                        const VerifiedBadge(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.profileEdit),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(148, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                textStyle: textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The avatar with a small camera badge; the whole photo is the button.
class _EditablePhoto extends StatelessWidget {
  const _EditablePhoto({required this.user, required this.onTap});

  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.actionChangePhoto,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            PersonAvatar(name: user.fullName ?? '', photoUrl: user.avatarUrl),
            const Positioned(
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.surface, width: 2),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: AppSizes.iconSmall,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSmall, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
