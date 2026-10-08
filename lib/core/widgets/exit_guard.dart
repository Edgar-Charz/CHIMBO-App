import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a screen at the bottom of the navigation stack so one Android back (button or swipe)
/// doesn't close the app: the first shows "Bonyeza nyuma tena ili kutoka.", a second one
/// while that message is showing closes it.
///
/// [onBack] runs first and returns true when it used the back itself (e.g. an earlier slide,
/// or the Nyumbani tab); then nothing else happens.
class ExitGuard extends StatefulWidget {
  const ExitGuard({super.key, required this.child, this.onBack});

  final Widget child;
  final bool Function()? onBack;

  @override
  State<ExitGuard> createState() => _ExitGuardState();
}

class _ExitGuardState extends State<ExitGuard> {
  DateTime? _lastBackAt;

  void _handleBack(bool didPop, Object? result) {
    if (didPop || (widget.onBack?.call() ?? false)) {
      return;
    }
    final now = DateTime.now();
    final lastBackAt = _lastBackAt;
    if (lastBackAt != null &&
        now.difference(lastBackAt) < AppDurations.exitConfirmWindow) {
      SystemNavigator.pop();
      return;
    }
    _lastBackAt = now;
    AppToast.of(context).info(context.l10n.pressBackAgainToExit);
  }

  @override
  Widget build(BuildContext context) {
    // `canPop: false` stops the system from closing the app; we decide in [_handleBack].
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: widget.child,
    );
  }
}
