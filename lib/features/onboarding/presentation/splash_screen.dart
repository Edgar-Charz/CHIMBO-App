import 'dart:async';

import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/widgets/app_logo.dart';
import 'package:chimbo/core/widgets/brand_slogan.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/app_images/application/app_images_controller.dart';
import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';
import 'package:chimbo/features/app_images/presentation/widgets/replaceable_image_slot.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/application/auth_state.dart';
import 'package:chimbo/features/onboarding/application/onboarding_controller.dart';
import 'package:chimbo/features/onboarding/presentation/widgets/splash_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// First screen: the logo fades in while the saved login is checked, then the app moves on.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// Long enough to read the brand, short enough not to annoy returning users.
  static const Duration displayTime = Duration(milliseconds: 1800);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const double _startScale = 0.9;

  /// The longest the splash waits for the onboarding / login pictures (counted from the start,
  /// so on a fast network it adds nothing; on a slow one the pictures finish on the screen).
  static const Duration _illustrationWaitLimit = Duration(seconds: 5);

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  )..forward();
  late final Animation<double> _curve = CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOutCubic,
  );

  /// Set when the saved login couldn't be checked; the splash then shows "Jaribu tena".
  ApiException? _restoreError;

  @override
  void initState() {
    super.initState();
    // Count from the first drawn frame: on a slow start Android's own launch screen covers the
    // app for a while, and the splash would otherwise be skipped.
    WidgetsBinding.instance.addPostFrameCallback((_) => _leaveWhenReady());
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Leaves once the brand has shown long enough **and** the saved login has been checked.
  /// The router then sends a logged-out customer to the phone screen. Someone heading to
  /// onboarding or login also waits (briefly) for those screens' pictures, so they don't
  /// appear a few seconds late.
  Future<void> _leaveWhenReady() async {
    final illustrations = _loadIllustrations().timeout(
      _illustrationWaitLimit,
      onTimeout: () {},
    );
    try {
      await Future.wait([
        Future<void>.delayed(SplashScreen.displayTime),
        ref.read(authControllerProvider.notifier).restoreSession(),
      ]);
    } on ApiException catch (error) {
      // Checking the saved login needs the server (e.g. no network): offer to try again.
      if (mounted) {
        setState(() => _restoreError = error);
      }
      return;
    }
    final goingHome =
        ref.read(authControllerProvider).status == AuthStatus.authenticated;
    if (!goingHome) {
      await illustrations;
    }
    if (mounted) {
      context.go(ref.read(onboardingControllerProvider).startRoute());
    }
  }

  /// The newest picture list from the admin, then every picture shown before Home, downloaded
  /// and decoded in parallel. A picture that fails just shows its fallback later.
  Future<void> _loadIllustrations() async {
    await ref.read(appImagesControllerProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    final images = ref.read(appImagesControllerProvider);
    await Future.wait([
      for (final slot in AppImageSlot.beforeHome)
        if (images[slot] case final image?)
          ReplaceableImageSlot.precache(context, image.url),
    ]);
  }

  void _retry() {
    setState(() => _restoreError = null);
    _leaveWhenReady();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.fullScreenSystemBars,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const SplashBackground(),
            Center(
              child: FadeTransition(
                opacity: _curve,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: _startScale,
                    end: 1,
                  ).animate(_curve),
                  child: const _SplashContent(),
                ),
              ),
            ),
            if (_restoreError case final error?)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: ErrorState(error: error, onRetry: _retry),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(markSize: AppSizes.splashLogo),
          const SizedBox(height: AppSpacing.lg),
          BrandSlogan(
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
