import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';

/// Kiswahili names, colours and icons for order statuses (blueprint §11.3).
extension OrderStatusLabel on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.pendingPayment => l10n.statusPendingPayment,
    OrderStatus.confirmed => l10n.statusConfirmed,
    OrderStatus.packed => l10n.statusPacked,
    OrderStatus.dispatched => l10n.statusDispatched,
    OrderStatus.inTransit => l10n.statusInTransit,
    OrderStatus.delivered => l10n.statusDelivered,
    OrderStatus.cancelled => l10n.statusCancelled,
    OrderStatus.expired => l10n.statusExpired,
  };

  /// Big word on the tracking banner ("Njiani" while on the road).
  String bannerTitle(AppLocalizations l10n) =>
      this == OrderStatus.inTransit ? l10n.trackingInTransitTitle : label(l10n);

  String bannerMessage(AppLocalizations l10n) => switch (this) {
    OrderStatus.pendingPayment => l10n.trackingPendingPayment,
    OrderStatus.confirmed => l10n.trackingConfirmed,
    OrderStatus.packed => l10n.trackingPacked,
    OrderStatus.dispatched => l10n.trackingDispatched,
    OrderStatus.inTransit => l10n.trackingInTransit,
    OrderStatus.delivered => l10n.trackingDelivered,
    OrderStatus.cancelled => l10n.trackingCancelled,
    OrderStatus.expired => l10n.trackingExpired,
  };

  /// Orange while moving, green when delivered, red when stopped (as in the design).
  Color get color => switch (this) {
    OrderStatus.delivered => AppColors.success,
    OrderStatus.cancelled || OrderStatus.expired => AppColors.danger,
    _ => AppColors.accent,
  };

  IconData get icon => switch (this) {
    OrderStatus.pendingPayment => Icons.hourglass_top_rounded,
    OrderStatus.confirmed => Icons.fact_check_outlined,
    OrderStatus.packed => Icons.inventory_2_outlined,
    OrderStatus.dispatched => Icons.outbox_outlined,
    OrderStatus.inTransit => Icons.local_shipping_outlined,
    OrderStatus.delivered => Icons.home_outlined,
    OrderStatus.cancelled || OrderStatus.expired => Icons.cancel_outlined,
  };
}

/// A pickup order ("Nitachukua mwenyewe dukani") uses the same statuses with its own words:
/// packed = "Tayari kuchukuliwa", delivered = "Imechukuliwa".
extension OrderStatusWords on Order {
  /// The word for [step] (default: the current status) on this order. The current status also says
  /// its stage: a payment being checked, the load being measured, a balance to pay.
  String statusLabel(AppLocalizations l10n, [OrderStatus? step]) {
    if (step == null) {
      if (stageLabel(l10n) case final stage?) {
        return stage;
      }
    }
    return switch ((isPickup, step ?? status)) {
      (true, OrderStatus.packed) => l10n.statusReadyForPickup,
      (true, OrderStatus.delivered) => l10n.statusPickedUp,
      (_, final other) => other.label(l10n),
    };
  }

  /// "Malipo yanakaguliwa" · "Tunapima mzigo" · "Salio la kulipa" — or null when the status says it all.
  String? stageLabel(AppLocalizations l10n) => switch (this) {
    Order(status: OrderStatus.pendingPayment, payment: final payment)
        when payment.isUnderReview =>
      l10n.statusCheckingPayment,
    Order(isAwaitingTransportPrice: true) => l10n.statusMeasuringLoad,
    Order(payment: final payment) when payment.isBalance =>
      l10n.statusBalanceDue,
    _ => null,
  };

  String bannerTitle(AppLocalizations l10n) =>
      stageLabel(l10n) ??
      (isPickup ? statusLabel(l10n) : status.bannerTitle(l10n));

  String bannerMessage(AppLocalizations l10n) => switch ((isPickup, status)) {
    (true, OrderStatus.packed) => l10n.trackingReadyForPickup,
    (true, OrderStatus.delivered) => l10n.trackingPickedUp,
    _ => status.bannerMessage(l10n),
  };

  /// The timeline's happy path: a pickup order is never sent.
  List<OrderStatus> get timelineSteps =>
      isPickup ? OrderStatus.pickupTimeline : OrderStatus.timeline;
}
