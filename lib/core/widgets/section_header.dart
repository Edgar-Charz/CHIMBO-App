import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
/// A section title with an optional action on the right (e.g. "Ona zote").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.isCompact = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: EdgeInsets.only(
        bottom: isCompact ? AppSpacing.xs : AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: isCompact
                  ? Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )
                  : Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (label != null)
            TextButton(onPressed: onAction, child: Text(label)),
        ],
      ),
    );
  }
}
