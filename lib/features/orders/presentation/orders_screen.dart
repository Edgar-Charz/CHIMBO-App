import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/order_feedback.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Oda Zangu (design PDF p.9): Zinazoendelea · Zimefika · Zote.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderGroup _group = OrderGroup.active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = ref.watch(ordersProvider(_group));
    final activeCount = ref
        .watch(ordersProvider(OrderGroup.active))
        .asData
        ?.value
        .total;
    final deliveredCount = ref
        .watch(ordersProvider(OrderGroup.delivered))
        .asData
        ?.value
        .total;
    final allCount = ref
        .watch(ordersProvider(OrderGroup.all))
        .asData
        ?.value
        .total;
    final tabs = {
      OrderGroup.active: (l10n.tabActiveOrders, activeCount),
      OrderGroup.delivered: (l10n.tabDeliveredOrders, deliveredCount),
      OrderGroup.all: (l10n.chipAll, allCount),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  for (final MapEntry(key: group, value: (label, count))
                      in tabs.entries)
                    ChoiceChip(
                      label: Text(
                        count == null
                            ? label
                            : l10n.orderTabCount(label, count),
                      ),
                      selected: group == _group,
                      onSelected: (_) => setState(() => _group = group),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(ordersProvider(_group).future),
              child: orders.when(
                data: (page) => page.orders.isEmpty
                    ? ListView(
                        children: [
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: switch (_group) {
                              OrderGroup.active => l10n.ordersActiveEmptyTitle,
                              OrderGroup.delivered =>
                                l10n.ordersDeliveredEmptyTitle,
                              OrderGroup.all => l10n.ordersEmptyTitle,
                            },
                            message: switch (_group) {
                              OrderGroup.active =>
                                l10n.ordersActiveEmptyMessage,
                              OrderGroup.delivered =>
                                l10n.ordersDeliveredEmptyMessage,
                              OrderGroup.all => l10n.ordersEmptyMessage,
                            },
                            actionLabel: l10n.actionStartShopping,
                            onAction: () => context.go(AppRoutes.discover),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: page.orders.length,
                        itemBuilder: (context, index) => OrderCard(
                          order: page.orders[index],
                          onReorder: () => reorderAndOpenCart(
                            context,
                            ref,
                            page.orders[index].id,
                          ),
                          onDownloadReceipt: () =>
                              downloadReceipt(context, ref, page.orders[index]),
                        ),
                      ),
                error: (error, _) => ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(ordersProvider(_group)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
