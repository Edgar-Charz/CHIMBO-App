import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/time/server_clock.dart';
import 'package:chimbo/features/catalog/application/offer_ticker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Ofa −15%": the red pill for a time-limited offer (cards, product page, cart and order lines).
class OfferLabel extends StatelessWidget {
  const OfferLabel({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        child: Text(
          context.l10n.offerPercentLabel(percent),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onDanger,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// How long a time-limited offer still runs: "10:23:34:12" (days:hours:minutes:seconds), or
/// "23:34:12" under a day; with [showLabel], "Inaisha baada ya 23:34:12".
///
/// Counts to the server's time ([offerTickerProvider]), so a wrong phone clock doesn't matter.
/// When it reaches zero it calls [onEnded] once, so the screen reloads: the server decides the
/// price. An offer already over when shown shows nothing and never reloads, so it can't loop.
class OfferCountdown extends ConsumerStatefulWidget {
  const OfferCountdown({
    super.key,
    required this.endsAt,
    required this.onEnded,
    this.showLabel = false,
    this.style,
  });

  final DateTime endsAt;
  final VoidCallback onEnded;
  final bool showLabel;
  final TextStyle? style;

  /// "DD:HH:MM:SS", or "HH:MM:SS" under a day; hours run 0–23.
  static String format(Duration left) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final time =
        '${twoDigits(left.inHours % Duration.hoursPerDay)}:'
        '${twoDigits(left.inMinutes % Duration.minutesPerHour)}:'
        '${twoDigits(left.inSeconds % Duration.secondsPerMinute)}';
    return left.inDays > 0 ? '${twoDigits(left.inDays)}:$time' : time;
  }

  @override
  ConsumerState<OfferCountdown> createState() => _OfferCountdownState();
}

class _OfferCountdownState extends ConsumerState<OfferCountdown> {
  /// Whether the offer was still running when first shown; only then may it trigger a reload.
  bool? _wasRunning;
  bool _hasEnded = false;

  @override
  void didUpdateWidget(OfferCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endsAt != widget.endsAt) {
      _wasRunning = null;
      _hasEnded = false;
    }
  }

  void _endOnce() {
    if (_hasEnded || _wasRunning != true) {
      return;
    }
    _hasEnded = true;
    // After this frame: a reload changes providers, which mustn't happen during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onEnded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now =
        ref.watch(offerTickerProvider).value ??
        ref.read(serverClockProvider.notifier).now();
    final left = widget.endsAt.difference(now);
    _wasRunning ??= left > Duration.zero;
    if (left <= Duration.zero) {
      _endOnce();
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final time = OfferCountdown.format(left);
    final style =
        widget.style ??
        Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600);
    return Semantics(
      label: l10n.offerEndsIn(time),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: AppSizes.iconSmall,
            color: style?.color ?? AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              widget.showLabel ? l10n.offerEndsIn(time) : time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Equal-width digits, so the text doesn't jiggle every second.
              style: style?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
