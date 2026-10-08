import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/brand_slogan.dart';
import 'package:chimbo/core/widgets/person_avatar.dart';
import 'package:flutter/material.dart';

/// "Habari za asubuhi, Joyce! 👋", the slogan and the search box (design PDF p.3).
class GreetingCard extends StatelessWidget {
  const GreetingCard({
    super.key,
    required this.fullName,
    required this.photoUrl,
    required this.now,
    required this.onSearchTap,
  });

  static const int _afternoonStartHour = 12;
  static const int _eveningStartHour = 16;

  final String fullName;

  /// The customer's profile photo; null → initials.
  final String? photoUrl;

  /// Passed in (not read inside), so the greeting is easy to test.
  final DateTime now;
  final VoidCallback onSearchTap;

  String _greeting(AppLocalizations l10n) {
    if (now.hour < _afternoonStartHour) {
      return l10n.greetingMorning;
    }
    return now.hour < _eveningStartHour
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final firstName = fullName.trim().split(' ').first;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentLight, AppColors.background],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.accentLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(l10n), style: textTheme.bodyLarge),
                      Text(
                        l10n.greetingName(firstName),
                        style: textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                PersonAvatar(name: fullName, photoUrl: photoUrl),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const BrandSlogan(),
            const SizedBox(height: AppSpacing.md),
            HomeSearchBar(onTap: onSearchTap),
          ],
        ),
      ),
    );
  }
}

/// Looks like a search field; opens Gundua, where the real search is.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.searchProductsHint,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
