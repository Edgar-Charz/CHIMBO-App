import 'dart:async';
import 'dart:math' as math;

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Reusable CHIMBO loading feedback for full-page, inline, and refresh states.
class ChimboLoader extends StatefulWidget {
  const ChimboLoader({
    super.key,
    this.compact = false,
    this.showMessage = true,
    this.loadingMessage,
    this.longWaitMessage,
    this.showMessageImmediately = false,
    this.indicatorSize,
    this.minimumOpacity = 0.58,
    this.messageStyle,
  });

  final bool compact;
  final bool showMessage;
  final String? loadingMessage;
  final String? longWaitMessage;
  final bool showMessageImmediately;
  final double? indicatorSize;
  final double minimumOpacity;
  final TextStyle? messageStyle;

  @override
  State<ChimboLoader> createState() => _ChimboLoaderState();
}

class _ChimboLoaderState extends State<ChimboLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  Timer? _loadingMessageTimer;
  Timer? _longWaitMessageTimer;
  bool _showLoadingMessage = false;
  bool _showLongWaitMessage = false;

  @override
  void initState() {
    super.initState();
    if (widget.showMessage) {
      if (widget.showMessageImmediately) {
        _showLoadingMessage = true;
      } else {
        _loadingMessageTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showLoadingMessage = true);
          }
        });
      }
      _longWaitMessageTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showLongWaitMessage = true);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller
        ..stop()
        ..value = 0.35;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _loadingMessageTimer?.cancel();
    _longWaitMessageTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingMessage =
        widget.loadingMessage ?? context.l10n.actionRetryLoading;
    final longWaitMessage =
        widget.longWaitMessage ?? context.l10n.loadingLongWait;
    final message = _showLongWaitMessage
        ? longWaitMessage
        : _showLoadingMessage
        ? loadingMessage
        : null;
    final size = widget.indicatorSize ?? (widget.compact ? 8.0 : 13.0);
    final gap = widget.compact ? AppSpacing.sm : AppSpacing.md;
    final barColors = [AppColors.primary, AppColors.gold, AppColors.primary];

    return Center(
      child: Semantics(
        liveRegion: true,
        label: message ?? loadingMessage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < barColors.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        right: index == barColors.length - 1 ? 0 : gap,
                      ),
                      child: _AnimatedDiamond(
                        size: size,
                        minimumOpacity: widget.minimumOpacity,
                        color: barColors[index],
                        outlined: index == 1,
                        progress: _diamondProgress(index),
                      ),
                    ),
                ],
              ),
            ),
            if (message != null) ...[
              SizedBox(height: widget.compact ? AppSpacing.xs : AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style:
                    widget.messageStyle ??
                    (widget.compact
                            ? Theme.of(context).textTheme.labelSmall
                            : Theme.of(context).textTheme.bodyMedium)
                        ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _diamondProgress(int index) {
    if (MediaQuery.of(context).disableAnimations) {
      return 0.45;
    }
    final phase = (_controller.value - index * 0.27) % 1;
    if (phase >= 0.62) {
      return 0;
    }
    return math.sin((phase / 0.62) * math.pi);
  }
}

class _AnimatedDiamond extends StatelessWidget {
  const _AnimatedDiamond({
    required this.size,
    required this.minimumOpacity,
    required this.color,
    required this.outlined,
    required this.progress,
  });

  final double size;
  final double minimumOpacity;
  final Color color;
  final bool outlined;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scale = 0.94 + progress * 0.08;
    final opacity = minimumOpacity + progress * (1 - minimumOpacity);
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: CustomPaint(
          size: Size.square(size),
          painter: _DiamondPainter(color: color, outlined: outlined),
        ),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  const _DiamondPainter({required this.color, required this.outlined});

  final Color color;
  final bool outlined;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    final paint = Paint()
      ..color = color
      ..style = outlined ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiamondPainter oldDelegate) =>
      color != oldDelegate.color || outlined != oldDelegate.outlined;
}

/// Pull-to-refresh with the same diamond loader and no Material spinner.
class ChimboRefreshIndicator extends StatefulWidget {
  const ChimboRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<ChimboRefreshIndicator> createState() => _ChimboRefreshIndicatorState();
}

class _ChimboRefreshIndicatorState extends State<ChimboRefreshIndicator> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator.noSpinner(onRefresh: _refresh, child: widget.child),
        if (_isRefreshing)
          const Positioned(
            top: AppSpacing.sm,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(height: 54, child: ChimboLoader(compact: true)),
            ),
          ),
      ],
    );
  }
}
