import 'package:flutter/material.dart';

/// Brand colours (blueprint §6.3). Values are approximate until the logo files arrive (D-16).
///
/// Rule: green = navigate/confirm, orange = buy.
abstract final class AppColors {
  static const Color primary = Color(0xFF0E3B2A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFFE4EEE8);
  static const Color accent = Color(0xFFF39200);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentLight = Color(0xFFFDEAD0);

  /// "Okoa zaidi" savings seal.
  static const Color gold = Color(0xFFD6A437);

  static const Color background = Color(0xFFFBF6EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E1D5);

  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B6B6B);

  // Soft icon tiles in menus (Wasifu), one tone per kind of item.
  static const Color goldLight = Color(0xFFFBF1DA);
  static const Color info = Color(0xFF2F6FDB);
  static const Color infoLight = Color(0xFFE6EFFC);
  static const Color purple = Color(0xFF7C5CC4);
  static const Color purpleLight = Color(0xFFEFE9FA);
  static const Color neutralLight = Color(0xFFEFEEEC);
  static const Color dangerLight = Color(0xFFFCE8E8);

  /// Soft shadow under product cards.
  static const Color cardShadow = Color(0x1F000000);

  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFD32F2F);
  static const Color onDanger = Color(0xFFFFFFFF);
}
