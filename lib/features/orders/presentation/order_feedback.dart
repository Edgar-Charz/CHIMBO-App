import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Agiza Tena": items back in the cart, then open Kikapu. Items the server skipped (sold out,
/// hidden …) are explained instead of the plain success message.
Future<void> reorderAndOpenCart(
  BuildContext context,
  WidgetRef ref,
  int orderId,
) async {
  final toast = AppToast.of(context);
  final l10n = context.l10n;
  final router = GoRouter.of(context);
  try {
    final skipped = await ref.read(orderActionsProvider).reorder(orderId);
    if (skipped.isEmpty) {
      toast.success(l10n.reorderDone);
    } else {
      toast.info(skipped.join(' '));
    }
    router.go(AppRoutes.cart);
  } on ApiException catch (error) {
    toast.error(l10n.errorMessage(error));
  }
}

/// Receipts come from the server as PDFs (Phase 4 step 27).
void showReceiptComingSoon(BuildContext context) {
  AppToast.of(context).info(context.l10n.comingSoonMessage);
}
