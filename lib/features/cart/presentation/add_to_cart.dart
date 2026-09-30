import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/cart/application/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Adds to the cart and tells the customer how it went: "Imeongezwa kikapuni · Ona Kikapu",
/// or the server's reason (MOQ, stock). Returns true when added.
Future<bool> addToCart(
  BuildContext context,
  WidgetRef ref, {
  required int productId,
  required int quantity,
}) async {
  final toast = AppToast.of(context);
  final l10n = context.l10n;
  final router = GoRouter.of(context);
  try {
    await ref.read(cartControllerProvider.notifier).add(productId, quantity);
    toast.success(
      l10n.addedToCart,
      actionLabel: l10n.actionViewCart,
      onAction: () => router.go(AppRoutes.cart),
    );
    return true;
  } on ApiException catch (error) {
    toast.error(l10n.errorMessage(error));
    return false;
  }
}
