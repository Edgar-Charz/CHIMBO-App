import 'package:chimbo/core/config/env.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_network_image.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/chimbo_loader.dart';
import 'package:chimbo/core/widgets/confirm_dialog.dart';
import 'package:chimbo/core/widgets/empty_state.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/catalog/application/product_requests_controller.dart';
import 'package:chimbo/features/catalog/data/models/product_request.dart';
import 'package:chimbo/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductRequestsScreen extends ConsumerWidget {
  const ProductRequestsScreen({super.key});

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    ProductRequest request,
  ) async {
    final l10n = context.l10n;
    final toast = AppToast.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.productRequestsCancelConfirmTitle,
      message: l10n.productRequestsCancelConfirmMessage,
      confirmLabel: l10n.productRequestsCancel,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(productRequestsControllerProvider.notifier)
          .cancel(request.id);
      if (!context.mounted) return;
      if (ref.read(productRequestsControllerProvider).asData?.value.isEmpty ??
          false) {
        Navigator.of(context).maybePop();
      } else {
        toast.success(l10n.productRequestsCancelSuccess);
      }
    } catch (error) {
      if (context.mounted) toast.error(l10n.errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final requests = ref.watch(productRequestsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.productRequestsTitle)),
      body: requests.when(
        data: (items) => items.isEmpty
            ? ListView(
                children: [
                  EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: l10n.productRequestsEmptyTitle,
                    message: l10n.productRequestsEmptyMessage,
                  ),
                ],
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(productRequestsControllerProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _RequestCard(
                    request: items[index],
                    onCancel: items[index].canCancel
                        ? () => _cancel(context, ref, items[index])
                        : null,
                  ),
                ),
              ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(productRequestsControllerProvider),
        ),
        loading: () => const ChimboLoader(),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, this.onCancel});

  final ProductRequest request;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (request.status) {
      'matched' => (l10n.productRequestsMatched, AppColors.primary),
      'notified' => (l10n.productRequestsNotified, AppColors.success),
      _ => (l10n.productRequestsPending, AppColors.accent),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(request.description),
            if (request.referenceImageUrl != null ||
                request.matchedProductImageUrl != null) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  if (request.referenceImageUrl case final imageUrl?)
                    _RequestPhoto(
                      url: imageUrl,
                      label: l10n.productRequestsReferencePhoto,
                      requiresAuthorization: true,
                    ),
                  if (request.matchedProductImageUrl case final imageUrl?)
                    _RequestPhoto(
                      url: imageUrl,
                      label: l10n.productRequestsMatchedPhoto,
                    ),
                ],
              ),
            ],
            if (request.matchedProductName case final productName?) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${l10n.productRequestsMatchedProduct}: $productName',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.productRequestsCancel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestPhoto extends ConsumerWidget {
  const _RequestPhoto({
    required this.url,
    required this.label,
    this.requiresAuthorization = false,
  });

  final String url;
  final String label;
  final bool requiresAuthorization;

  Widget _image(Map<String, String> headers) {
    if (!requiresAuthorization) {
      return AppNetworkImage(
        url: url,
        placeholderIcon: ProductCard.placeholderIcon,
      );
    }

    return Image.network(
      url,
      headers: {...Env.tunnelHeaders, ...headers},
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ColoredBox(
              color: AppColors.background,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.background,
        child: Icon(
          ProductCard.placeholderIcon,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = requiresAuthorization
        ? ref.watch(productRequestImageHeadersProvider)
        : const AsyncData<Map<String, String>>({});

    return headers.when(
      data: (requestHeaders) => SizedBox(
        width: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: AspectRatio(
                aspectRatio: 1,
                child: Material(
                  color: AppColors.background,
                  child: InkWell(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => Dialog(
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: InteractiveViewer(
                            child: _image(requestHeaders),
                          ),
                        ),
                      ),
                    ),
                    child: _image(requestHeaders),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.square(
        dimension: 104,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
