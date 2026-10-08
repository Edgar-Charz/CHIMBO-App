import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/widgets/app_logo.dart';
import 'package:chimbo/core/widgets/step_progress.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/app_images/presentation/widgets/replaceable_image_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Shared frame of the login screens: small logo, back arrow, step dots (registration only),
/// picture, title and subtitle, then the screen's own form in [children].
class AuthStepLayout extends StatelessWidget {
  const AuthStepLayout({
    super.key,
    required this.illustration,
    required this.illustrationSlot,
    required this.illustrationIcons,
    required this.title,
    required this.subtitle,
    required this.children,
    this.step,
    this.onBack,
  });

  /// Phone, SMS code, PIN, business details.
  static const int totalSteps = 4;

  /// Pictures are 16:10 landscape (see `assets/images/README.md`).
  static const double _illustrationAspectRatio = 16 / 10;

  /// The smallest the picture gets on a short screen before the page starts to scroll.
  static const double _illustrationMinHeight = 72;

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.xl,
    AppSpacing.sm,
    AppSpacing.xl,
    AppSpacing.xl,
  );

  /// The registration step shown in the dots; null on login and "Umesahau PIN?" screens.
  final int? step;
  final String illustration;
  final AppImageSlot illustrationSlot;
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
          // Fills the screen exactly; scrolls only when even the smallest picture can't fit.
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              padding: _padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewport.maxHeight - _padding.vertical,
                ),
                // Sizes the column to its content, so the picture below can take what is left.
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(onBack: onBack),
                      if (step case final current?) ...[
                        const SizedBox(height: AppSpacing.lg),
                        StepProgress(current: current, total: totalSteps),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: _ShrinkToFit(
                          minHeight: _illustrationMinHeight,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _illustrationAspectRatio,
                              child: ReplaceableImageSlot(
                                slot: illustrationSlot,
                                asset: illustration,
                                placeholderIcons: illustrationIcons,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.large,
                                ),
                              ),
                            ),
                          ),
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
          ),
        ),
      ),
    );
  }
}

/// Asks the column for only [minHeight] when it measures its content, so the picture gets
/// whatever height is left on the screen (up to its full size) instead of pushing the form
/// below the bottom edge.
class _ShrinkToFit extends SingleChildRenderObjectWidget {
  const _ShrinkToFit({required this.minHeight, required super.child});

  final double minHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderShrinkToFit(minHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderShrinkToFit renderObject,
  ) {
    renderObject.minHeight = minHeight;
  }
}

class _RenderShrinkToFit extends RenderProxyBox {
  _RenderShrinkToFit(this._minHeight);

  double _minHeight;

  set minHeight(double value) {
    if (value != _minHeight) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) => _minHeight;

  @override
  double computeMaxIntrinsicHeight(double width) => _minHeight;
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
