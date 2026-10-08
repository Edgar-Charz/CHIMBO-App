import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:chimbo/features/orders/presentation/order_feedback.dart';
import 'package:chimbo/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final tabs = {
      OrderGroup.active: l10n.tabActiveOrders,
      OrderGroup.delivered: l10n.tabDeliveredOrders,
      OrderGroup.all: l10n.chipAll,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            // Wrap: the tabs move to a second line instead of overflowing with large text.
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final MapEntry(key: group, value: label) in tabs.entries)
                  ChoiceChip(
                    label: Text(label),
                    selected: group == _group,
                    onSelected: (_) => setState(() => _group = group),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(ordersProvider(_group).future),
              child: orders.when(
                data: (list) => list.isEmpty
                    ? ListView(
                        children: [
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: l10n.ordersEmptyTitle,
                            message: l10n.ordersEmptyMessage,
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) => OrderCard(
                          order: list[index],
                          onReorder: () =>
                              reorderAndOpenCart(context, ref, list[index].id),
                          onDownloadReceipt: () =>
                              downloadReceipt(context, ref, list[index]),
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
