import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// What the customer chose in the photo sheet.
enum ProfilePhotoAction { gallery, camera, remove }

/// "Picha ya wasifu": pick from the gallery, take one, or (with a photo) remove it.
/// Returns null when dismissed.
Future<ProfilePhotoAction?> showProfilePhotoSheet(
  BuildContext context, {
  required bool hasPhoto,
}) {
  return showModalBottomSheet<ProfilePhotoAction>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = context.l10n;
      Widget option(ProfilePhotoAction action, IconData icon, String label) {
        final color = action == ProfilePhotoAction.remove
            ? AppColors.danger
            : AppColors.textPrimary;
        return ListTile(
          leading: Icon(icon, color: color),
          title: Text(label, style: TextStyle(color: color)),
          onTap: () => Navigator.of(context).pop(action),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  l10n.profilePhotoTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              option(
                ProfilePhotoAction.gallery,
                Icons.photo_library_outlined,
                l10n.actionChoosePhoto,
              ),
              option(
                ProfilePhotoAction.camera,
                Icons.photo_camera_outlined,
                l10n.actionTakePhoto,
              ),
              if (hasPhoto)
                option(
                  ProfilePhotoAction.remove,
                  Icons.delete_outline_rounded,
                  l10n.actionRemovePhoto,
                ),
            ],
          ),
        ),
      );
    },
  );
}
