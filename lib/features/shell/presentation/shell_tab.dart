import 'package:chimbo/core/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The 5 bottom-navigation tabs, in display order (must match the router's branches).
enum ShellTab {
  home(Icons.home_outlined, Icons.home_rounded),
  discover(Icons.search_rounded, Icons.search_rounded),
  cart(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
  orders(Icons.article_outlined, Icons.article_rounded),
  profile(Icons.person_outline_rounded, Icons.person_rounded);

  const ShellTab(this.icon, this.selectedIcon);

  final IconData icon;
  final IconData selectedIcon;

  String label(AppLocalizations l10n) {
    return switch (this) {
      ShellTab.home => l10n.navHome,
      ShellTab.discover => l10n.navDiscover,
      ShellTab.cart => l10n.navCart,
      ShellTab.orders => l10n.navOrders,
      ShellTab.profile => l10n.navProfile,
    };
  }
}
