import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Shows any error in plain words with a *Jaribu tena* button.
class ErrorState extends StatefulWidget {
  const ErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.isLoading = false,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool isLoading;

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  bool _isRetrying = false;

  @override
  void didUpdateWidget(covariant ErrorState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error ||
        (oldWidget.isLoading && !widget.isLoading)) {
      _isRetrying = false;
    }
  }

  void _retry() {
    if (_isRetrying || widget.isLoading) {
      return;
    }
    setState(() => _isRetrying = true);
    widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_isRetrying || widget.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.actionRetryLoading,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final isOffline = switch (widget.error) {
      ApiException(code: ApiErrorCode.network) => true,
      _ => false,
    };
    return EmptyState(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      message: l10n.errorMessage(widget.error),
      actionLabel: l10n.actionRetry,
      onAction: _retry,
    );
  }
}
