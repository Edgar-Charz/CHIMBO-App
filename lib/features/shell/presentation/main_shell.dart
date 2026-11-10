import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:chimbo/core/widgets/count_icon_badge.dart';
import 'package:chimbo/core/widgets/exit_guard.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:chimbo/features/shell/presentation/shell_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
export 'package:chimbo/features/shell/presentation/shell_tab.dart';

/// The frame around the 5 tabs: the current tab's screen + the bottom navigation bar.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cartCount = ref.watch(cartCountProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.tabSystemBars,
      child: ExitGuard(
        onBack: _backToHome,
        child: Scaffold(
          // Keep tab content above the translucent bar so the last row remains reachable.
          extendBody: false,
          body: navigationShell,
          bottomNavigationBar: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.84),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.34),
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _NavigationSpotlight(
                        selectedIndex: navigationShell.currentIndex,
                      ),
                    ),
                    NavigationBar(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _openTab,
                      backgroundColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      destinations: [
                        for (final tab in ShellTab.values)
                          NavigationDestination(
                            icon: Transform.translate(
                              offset: const Offset(0, 2),
                              child: tab == ShellTab.cart
                                  ? CountIconBadge(
                                      count: cartCount,
                                      icon: tab.icon,
                                    )
                                  : Icon(tab.icon),
                            ),
                            selectedIcon: Transform.translate(
                              offset: const Offset(0, 2),
                              child: tab == ShellTab.cart
                                  ? CountIconBadge(
                                      count: cartCount,
                                      icon: tab.selectedIcon,
                                    )
                                  : Icon(tab.selectedIcon),
                            ),
                            label: tab.label(l10n),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Back on another tab's first screen goes to Nyumbani before offering to exit.
  bool _backToHome() {
    if (navigationShell.currentIndex == ShellTab.home.index) {
      return false;
    }
    navigationShell.goBranch(ShellTab.home.index);
    return true;
  }

  /// Tapping the current tab again returns it to its first screen.
  void _openTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// A brief warm light sweep follows the selected item when customers change tabs.
class _NavigationSpotlight extends StatefulWidget {
  const _NavigationSpotlight({required this.selectedIndex});

  final int selectedIndex;

  @override
  State<_NavigationSpotlight> createState() => _NavigationSpotlightState();
}

class _NavigationSpotlightState extends State<_NavigationSpotlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: 1,
  );

  @override
  void didUpdateWidget(_NavigationSpotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / ShellTab.values.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              left: tabWidth * widget.selectedIndex,
              top: 1,
              width: tabWidth,
              height: 62,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final progress = _controller.value;
                    final glow = math.sin(math.pi * progress);
                    return Opacity(
                      opacity: glow * 0.65,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: RadialGradient(
                            center: Alignment(-0.9 + progress * 1.8, -0.25),
                            radius: 1.05,
                            colors: [
                              AppColors.gold.withValues(alpha: 0.55),
                              AppColors.accentLight.withValues(alpha: 0.46),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.48, 1],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              left: tabWidth * widget.selectedIndex + (tabWidth - 18) / 2,
              top: 60,
              width: 18,
              height: 3,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
