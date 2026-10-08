import 'package:cached_network_image/cached_network_image.dart';
import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// A round profile photo; without one (or while it loads) a green circle with "JJ" for
/// "Joyce Joseph".
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = AppSizes.avatarRadius,
  });

  static const int _maxInitials = 2;
  static const double _textScale = 0.6;

  final String name;
  final String? photoUrl;
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
    final url = photoUrl;
    if (url == null) {
      return _initialsCircle();
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        // Same tunnel header as the API, or ngrok sends a warning page instead of the image.
        httpHeaders: Env.tunnelHeaders,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, _) => _initialsCircle(),
        errorWidget: (_, _, _) => _initialsCircle(),
      ),
    );
  }

  Widget _initialsCircle() {
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
