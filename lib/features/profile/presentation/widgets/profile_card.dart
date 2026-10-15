import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/verified_badge.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:chimbo/features/profile/presentation/widgets/profile_photo_control.dart';
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
          children: [
            Row(
              children: [
                ProfilePhotoControl(user: profile.user, onTap: onChangePhoto),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.user.fullName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton(
                            onPressed: onEdit,
                            tooltip: l10n.profileEdit,
                            style: IconButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.medium,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
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
