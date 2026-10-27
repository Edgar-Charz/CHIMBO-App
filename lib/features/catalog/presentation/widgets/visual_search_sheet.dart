import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Choice made in the visual search modal sheet.
enum VisualSearchSource { camera, gallery }

const double _photoMaxSide = 1080;
const int _photoQuality = 85;

/// Modal bottom sheet for choosing between camera and gallery.
Future<VisualSearchSource?> showVisualSearchSheet(BuildContext context) {
  return showModalBottomSheet<VisualSearchSource>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = context.l10n;
      Widget option(VisualSearchSource source, IconData icon, String label) {
        return ListTile(
          leading: Icon(icon, color: AppColors.textPrimary),
          title: Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          onTap: () => Navigator.of(context).pop(source),
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
                  l10n.visualSearchTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              option(
                VisualSearchSource.camera,
                Icons.photo_camera_outlined,
                l10n.visualSearchTakePhoto,
              ),
              option(
                VisualSearchSource.gallery,
                Icons.photo_library_outlined,
                l10n.visualSearchChooseGallery,
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows the visual search sheet and picks an image via [ImagePicker].
Future<String?> pickProductImage(
  BuildContext context, {
  ImagePicker? picker,
}) async {
  final source = await showVisualSearchSheet(context);
  if (source == null) {
    return null;
  }
  final imagePicker = picker ?? ImagePicker();
  final photo = await imagePicker.pickImage(
    source: source == VisualSearchSource.camera
        ? ImageSource.camera
        : ImageSource.gallery,
    maxWidth: _photoMaxSide,
    maxHeight: _photoMaxSide,
    imageQuality: _photoQuality,
  );
  return photo?.path;
}
