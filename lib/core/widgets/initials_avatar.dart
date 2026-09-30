import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Green circle with "JJ" for "Joyce Joseph" (photos come with the avatar upload later).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = AppSizes.avatarRadius,
  });

  static const int _maxInitials = 2;
  static const double _textScale = 0.6;

  final String name;
  final double radius;

  String get _initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(_maxInitials)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.onPrimary,
          fontSize: radius * _textScale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
