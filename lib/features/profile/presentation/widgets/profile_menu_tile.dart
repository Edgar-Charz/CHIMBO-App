import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Soft colour behind a menu icon, as in the Wasifu design.
enum MenuTone {
  green(AppColors.primaryLight, AppColors.primary),
  orange(AppColors.accentLight, AppColors.accent),
  gold(AppColors.goldLight, AppColors.gold),
  blue(AppColors.infoLight, AppColors.info),
  purple(AppColors.purpleLight, AppColors.purple),
  red(AppColors.dangerLight, AppColors.danger),
  grey(AppColors.neutralLight, AppColors.textSecondary);

  const MenuTone(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

/// One white card row: coloured icon, title, short explanation, chevron.
class ProfileMenuTile extends StatefulWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final MenuTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<ProfileMenuTile> createState() => _ProfileMenuTileState();
}

class _ProfileMenuTileState extends State<ProfileMenuTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedScale(
      scale: _isPressed ? 0.99 : 1,
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (isHighlighted) {
            setState(() => _isPressed = isHighlighted);
          },
          borderRadius: BorderRadius.circular(AppRadius.large),
          splashColor: AppColors.primaryLight,
          highlightColor: AppColors.primaryLight.withValues(alpha: 0.55),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            leading: Container(
              width: AppSizes.menuIconBox,
              height: AppSizes.menuIconBox,
              decoration: BoxDecoration(
                color: widget.tone.background,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(widget.icon, color: widget.tone.foreground),
            ),
            title: Text(
              widget.title,
              style: textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            subtitle: Text(widget.subtitle, style: textTheme.bodySmall),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
