import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Shows any error in plain words with a *Jaribu tena* button.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOffline = switch (error) {
      ApiException(code: ApiErrorCode.network) => true,
      _ => false,
    };
    return EmptyState(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      message: l10n.errorMessage(error),
      actionLabel: l10n.actionRetry,
      onAction: onRetry,
    );
  }
}
