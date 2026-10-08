import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/exit_guard.dart';
import 'package:chimbo/features/onboarding/application/onboarding_controller.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/onboarding_slides.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/page_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Three swipeable intro slides, shown once per install.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<Widget> _slides = [
    ProductsSlide(),
    WholesaleSlide(),
    DeliverySlide(),
  ];

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isFinishing = false;

  bool get _isLastSlide => _currentIndex == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onButtonPressed() async {
    if (!_isLastSlide) {
      await _pageController.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
      return;
    }
    setState(() => _isFinishing = true);
    final nextRoute = await ref
        .read(onboardingControllerProvider)
        .completeOnboarding();
    if (mounted) {
      context.go(nextRoute);
    }
  }

  /// Android back goes to the previous slide; on the first one, [ExitGuard] takes over.
  bool _onBackPressed() {
    if (_currentIndex == 0) {
      return false;
    }
    _pageController.previousPage(
      duration: AppDurations.medium,
      curve: Curves.easeInOut,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.fullScreenSystemBars,
      child: ExitGuard(
        onBack: _onBackPressed,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    children: _slides,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      PageDots(
                        count: _slides.length,
                        currentIndex: _currentIndex,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Orange on the last slide: green = navigate, orange = start buying.
                      AppButton(
                        label: _isLastSlide
                            ? l10n.actionGetStarted
                            : l10n.actionContinue,
                        variant: _isLastSlide
                            ? AppButtonVariant.accent
                            : AppButtonVariant.primary,
                        isLoading: _isFinishing,
                        onPressed: _onButtonPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
