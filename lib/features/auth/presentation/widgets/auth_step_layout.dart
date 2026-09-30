import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/widgets/app_logo.dart';
import 'package:chimbo/core/widgets/image_slot.dart';
import 'package:chimbo/core/widgets/step_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared frame of the 3 registration steps: small logo, back arrow (steps 2–3), step dots,
/// picture, title and subtitle, then the step's own form in [children].
class AuthStepLayout extends StatelessWidget {
  const AuthStepLayout({
    super.key,
    required this.step,
    required this.illustration,
    required this.illustrationIcons,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
  });

  static const int totalSteps = 3;

  /// Pictures are 16:10 landscape (see `assets/images/README.md`).
  static const double _illustrationAspectRatio = 16 / 10;

  final int step;
  final String illustration;
  final List<IconData> illustrationIcons;
  final String title;
  final Widget subtitle;
  final List<Widget> children;

  /// Shows the back arrow when set.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.fullScreenSystemBars,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onBack: onBack),
                const SizedBox(height: AppSpacing.lg),
                StepProgress(current: step, total: totalSteps),
                const SizedBox(height: AppSpacing.lg),
                AspectRatio(
                  aspectRatio: _illustrationAspectRatio,
                  child: ImageSlot(
                    asset: illustration,
                    placeholderIcons: illustrationIcons,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                  child: subtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo centred, back arrow on the left of the same row.
class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final back = onBack;
    return Stack(
      alignment: Alignment.center,
      children: [
        const AppLogo(markSize: AppSizes.headerLogo),
        if (back != null)
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: back,
              tooltip: context.l10n.actionBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
      ],
    );
  }
}
