import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/person_avatar.dart';
import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:flutter/material.dart';

/// Profile photo with a camera badge; optionally shows a labelled edit action.
class ProfilePhotoControl extends StatelessWidget {
  const ProfilePhotoControl({
    super.key,
    required this.user,
    required this.onTap,
    this.showLabel = false,
  });

  final AppUser user;
  final VoidCallback onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final photo = Semantics(
      button: true,
      label: context.l10n.actionChangePhoto,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          children: [
            PersonAvatar(
              name: user.fullName ?? '',
              photoUrl: user.avatarUrl,
              radius: AppSizes.avatarRadius,
            ),
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

    if (!showLabel) {
      return photo;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        photo,
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.edit_outlined),
          label: Text(context.l10n.actionChangePhoto),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }
}
