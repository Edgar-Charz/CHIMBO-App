import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/profile/application/profile_controller.dart';
import 'package:chimbo/features/profile/presentation/widgets/profile_photo_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

const double _photoMaxSide = 1080;
const int _photoQuality = 85;

/// Runs the shared profile photo picker and saves the selected photo.
Future<void> changeProfilePhoto(
  BuildContext context,
  WidgetRef ref, {
  required bool hasPhoto,
}) async {
  final toast = AppToast.of(context);
  final l10n = context.l10n;
  final controller = ref.read(profileControllerProvider.notifier);
  final action = await showProfilePhotoSheet(context, hasPhoto: hasPhoto);
  try {
    switch (action) {
      case null:
        return;
      case ProfilePhotoAction.remove:
        await controller.removePhoto();
        toast.success(l10n.profilePhotoRemoved);
      case ProfilePhotoAction.gallery || ProfilePhotoAction.camera:
        final photo = await ImagePicker().pickImage(
          source: action == ProfilePhotoAction.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: _photoMaxSide,
          maxHeight: _photoMaxSide,
          imageQuality: _photoQuality,
        );
        if (photo == null) {
          return;
        }
        toast.info(l10n.profilePhotoUploading);
        await controller.changePhoto(photo.path);
        toast.success(l10n.profilePhotoSaved);
    }
  } on ApiException catch (error) {
    if (context.mounted) {
      toast.error(l10n.errorMessage(error));
    }
  }
}
