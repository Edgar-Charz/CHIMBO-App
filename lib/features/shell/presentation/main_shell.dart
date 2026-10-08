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
      // Screens opened inside a tab still close with back as usual; this only acts on a
      // tab's first screen.
      child: ExitGuard(
        onBack: _backToHome,
        child: Scaffold(
          body: navigationShell,
          // Thin line above the bar separates it from the cream page, as in the design.
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _openTab,
              destinations: [
                for (final tab in ShellTab.values)
                  NavigationDestination(
                    icon: tab == ShellTab.cart
                        ? CountIconBadge(count: cartCount, icon: tab.icon)
                        : Icon(tab.icon),
                    selectedIcon: tab == ShellTab.cart
                        ? CountIconBadge(
                            count: cartCount,
                            icon: tab.selectedIcon,
                          )
                        : Icon(tab.selectedIcon),
                    label: tab.label(l10n),
                  ),
              ],
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
