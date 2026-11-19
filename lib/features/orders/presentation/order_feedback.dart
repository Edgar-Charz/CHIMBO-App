import 'dart:io';

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/orders/application/orders_providers.dart';
import 'package:chimbo/features/orders/data/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
      toast.success(l10n.reorderDone, animateIcon: true);
    } else {
      toast.info(skipped.join(' '));
    }
    router.go(AppRoutes.cart);
  } on ApiException catch (error) {
    toast.error(l10n.errorMessage(error));
  }
}

/// "Pakua Risiti": opens the system picker so the customer can choose where to save the PDF.
Future<void> downloadReceipt(
  BuildContext context,
  WidgetRef ref,
  Order order,
) async {
  final toast = AppToast.of(context);
  final l10n = context.l10n;
  toast.info(l10n.receiptDownloading);
  try {
    await ref.read(orderActionsProvider).downloadReceipt(order);
  } on ApiException catch (error) {
    toast.error(l10n.errorMessage(error));
  }
}

/// "Shiriki Risiti": downloads the PDF to a temp file, then opens the OS share sheet so the
/// customer can send it to WhatsApp, email, Telegram, etc.
Future<void> shareReceipt(
  BuildContext context,
  WidgetRef ref,
  Order order,
) async {
  final toast = AppToast.of(context);
  final l10n = context.l10n;
  toast.info(l10n.receiptSharing);
  try {
    final bytes = await ref
        .read(orderActionsProvider)
        .downloadReceiptBytes(order.id);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Risiti-${order.number}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Risiti-${order.number}',
      ),
    );
  } on ApiException catch (error) {
    if (context.mounted) toast.error(l10n.errorMessage(error));
  } catch (_) {
    if (context.mounted) toast.error(l10n.errorUnknown);
  }
}
