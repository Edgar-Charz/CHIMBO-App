import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Green tick + "Imethibitishwa" for verified sellers and businesses.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.verified_rounded,
          size: AppSizes.iconSmall,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          context.l10n.verifiedBusiness,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.success),
        ),
      ],
    );
  }
}
