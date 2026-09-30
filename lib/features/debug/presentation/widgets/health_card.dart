import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/debug/application/health_provider.dart';
import 'package:chimbo/features/debug/data/health_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calls `GET /health` and shows whether the app can reach the API and database.
class HealthCard extends ConsumerWidget {
  const HealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthProvider);
    void checkAgain() => ref.invalidate(healthProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoRow(
              label: context.l10n.debugApiAddress,
              value: Env.apiBaseUrl,
            ),
            const Divider(height: AppSpacing.xl),
            health.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  ErrorState(error: error, onRetry: checkAgain),
              data: (status) =>
                  _HealthDetails(status: status, onCheckAgain: checkAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthDetails extends StatelessWidget {
  const _HealthDetails({required this.status, required this.onCheckAgain});

  final HealthStatus status;
  final VoidCallback onCheckAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusRow(label: l10n.debugServerStatus, isOk: status.isServerOk),
        _StatusRow(label: l10n.debugDatabaseStatus, isOk: status.isDatabaseOk),
        _InfoRow(label: l10n.debugApiVersion, value: status.version),
        _InfoRow(
          label: l10n.debugServerTime,
          value: AppDates.formatDateTime(status.time, l10n.localeName),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onCheckAgain,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.actionRetry),
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.isOk});

  final String label;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = isOk ? AppColors.success : AppColors.danger;
    return _InfoRow(
      label: label,
      value: isOk ? l10n.debugStatusOk : l10n.debugStatusProblem,
      valueColor: color,
      leading: Icon(
        isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: AppSizes.iconSmall,
        color: color,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.leading,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = leading;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (icon != null) ...[icon, const SizedBox(width: AppSpacing.xs)],
          Flexible(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(color: valueColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
