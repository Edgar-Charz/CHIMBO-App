import 'dart:async';

import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

enum _ToastKind {
  success(Icons.check_circle_rounded, AppColors.success),
  error(Icons.error_rounded, AppColors.danger),
  info(Icons.info_rounded, AppColors.accent);

  const _ToastKind(this.icon, this.color);

  final IconData icon;
  final Color color;
}

/// Short messages that slide down from the top and hide themselves after a few seconds
/// ("Imeongezwa kikapuni · Ona Kikapu"). Used instead of snackbars everywhere, so every message
/// looks the same. Swipe up to dismiss; a new message replaces the one showing.
///
/// Take it before an `await` (`final toast = AppToast.of(context);`) and call it after, so no
/// context is used across the gap.
class AppToast {
  AppToast.of(BuildContext context)
    : _overlay = Overlay.of(context, rootOverlay: true);

  static const Duration _visibleFor = Duration(seconds: 3);
  static const Duration _visibleWithActionFor = Duration(seconds: 4);

  /// Only one toast at a time.
  static OverlayEntry? _current;

  final OverlayState _overlay;

  void success(String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(_ToastKind.success, message, actionLabel, onAction);
  }

  void error(String message) => _show(_ToastKind.error, message, null, null);

  void info(String message) => _show(_ToastKind.info, message, null, null);

  void _show(
    _ToastKind kind,
    String message,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    _removeCurrent();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastView(
        kind: kind,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        visibleFor: actionLabel == null ? _visibleFor : _visibleWithActionFor,
        onDismissed: () {
          if (identical(_current, entry)) {
            _removeCurrent();
          }
        },
      ),
    );
    _current = entry;
    _overlay.insert(entry);
  }

  static void _removeCurrent() {
    final current = _current;
    if (current != null && current.mounted) {
      current.remove();
    }
    _current = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.kind,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.visibleFor,
    required this.onDismissed,
  });

  final _ToastKind kind;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration visibleFor;
  final VoidCallback onDismissed;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  )..forward();
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
  late final Timer _hideTimer;

  @override
  void initState() {
    super.initState();
    _hideTimer = Timer(widget.visibleFor, _hide);
  }

  @override
  void dispose() {
    _hideTimer.cancel();
    _animation.dispose();
    super.dispose();
  }

  Future<void> _hide() async {
    if (!mounted) {
      return;
    }
    await _animation.reverse();
    widget.onDismissed();
  }

  void _onAction() {
    widget.onAction?.call();
    _hide();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.actionLabel;
    final textTheme = Theme.of(context).textTheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _animation,
            child: Dismissible(
              key: const ValueKey('toast'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismissed(),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Material(
                  color: AppColors.surface,
                  elevation: AppSizes.toastElevation,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border(
                        left: BorderSide(
                          color: widget.kind.color,
                          width: AppSpacing.xs,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.xs,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(widget.kind.icon, color: widget.kind.color),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(
                              widget.message,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        if (action != null)
                          TextButton(
                            onPressed: _onAction,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: textTheme.labelLarge,
                            ),
                            child: Text(action),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
