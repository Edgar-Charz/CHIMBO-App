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
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final l10n = context.l10n;
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    l10n.visualSearchTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _VisualSearchOption(
                  icon: Icons.photo_camera_outlined,
                  label: l10n.visualSearchTakePhoto,
                  gradient: const [AppColors.primaryLight, AppColors.surface],
                  pressedGradient: const [
                    AppColors.primaryLight,
                    AppColors.primaryLight,
                  ],
                  iconGradient: const [AppColors.primary, AppColors.primary],
                  iconColor: AppColors.onPrimary,
                  borderColor: AppColors.primary.withValues(alpha: 0.16),
                  onTap: () =>
                      Navigator.of(context).pop(VisualSearchSource.camera),
                ),
                const SizedBox(height: AppSpacing.sm),
                _VisualSearchOption(
                  icon: Icons.photo_library_outlined,
                  label: l10n.visualSearchChooseGallery,
                  gradient: const [AppColors.accentLight, AppColors.surface],
                  pressedGradient: const [
                    AppColors.accentLight,
                    AppColors.accentLight,
                  ],
                  iconGradient: const [AppColors.accent, AppColors.gold],
                  iconColor: AppColors.onAccent,
                  borderColor: AppColors.accent.withValues(alpha: 0.20),
                  onTap: () =>
                      Navigator.of(context).pop(VisualSearchSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _VisualSearchOption extends StatefulWidget {
  const _VisualSearchOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.pressedGradient,
    required this.iconGradient,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> gradient;
  final List<Color> pressedGradient;
  final List<Color> iconGradient;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<_VisualSearchOption> createState() => _VisualSearchOptionState();
}

class _VisualSearchOptionState extends State<_VisualSearchOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.large);
    return AnimatedScale(
      scale: _isPressed ? 0.975 : 1,
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (isHighlighted) {
            setState(() => _isPressed = isHighlighted);
          },
          borderRadius: radius,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: widget.borderColor),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isPressed ? widget.pressedGradient : widget.gradient,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.iconGradient,
                      ),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppSizes.iconSmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
