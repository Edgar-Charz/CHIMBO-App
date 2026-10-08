import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/support/application/support_providers.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Vigezo na Masharti" or "Sera ya Faragha": the server's text, one paragraph per block.
/// Public, so it opens from the login screen too.
class LegalPageScreen extends ConsumerWidget {
  const LegalPageScreen({super.key, required this.type});

  final LegalPageType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final page = ref.watch(legalPageProvider(type));
    final fallbackTitle = switch (type) {
      LegalPageType.terms => l10n.menuTerms,
      LegalPageType.privacy => l10n.menuPrivacy,
    };
    return Scaffold(
      appBar: AppBar(title: Text(page.value?.title ?? fallbackTitle)),
      body: page.when(
        data: (value) => _PageBody(page: value),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(legalPageProvider(type)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page});

  final LegalPage page;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.legalUpdatedOn(
              AppDates.formatDate(page.updatedAt, l10n.localeName),
            ),
            style: textTheme.bodySmall,
          ),
          for (final paragraph in page.paragraphs)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(paragraph, style: textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}
