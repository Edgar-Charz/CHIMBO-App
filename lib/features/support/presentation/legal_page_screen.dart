import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/dates.dart';
import 'package:chimbo/core/widgets/chimbo_loader.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/support/application/support_providers.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
/// "Vigezo na Masharti" or "Sera ya Faragha": the server's safe formatted text.
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
        loading: () => const ChimboLoader(),
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
          if (page.formattedBlocks.isNotEmpty)
            for (final block in page.formattedBlocks)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: _FormattedLegalBlock(block: block),
              )
          else
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

class _FormattedLegalBlock extends StatefulWidget {
  const _FormattedLegalBlock({required this.block});

  final LegalPageBlock block;

  @override
  State<_FormattedLegalBlock> createState() => _FormattedLegalBlockState();
}

class _FormattedLegalBlockState extends State<_FormattedLegalBlock> {
  final Map<String, TapGestureRecognizer> _linkRecognizers = {};

  @override
  void didUpdateWidget(covariant _FormattedLegalBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeLinks = widget.block.runs
        .map((run) => run.linkUrl)
        .whereType<String>()
        .toSet();
    for (final entry in _linkRecognizers.entries.toList()) {
      if (!activeLinks.contains(entry.key)) {
        entry.value.dispose();
        _linkRecognizers.remove(entry.key);
      }
    }
  }

  @override
  void dispose() {
    for (final recognizer in _linkRecognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizerFor(String url) =>
      _linkRecognizers.putIfAbsent(
        url,
        () => TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url)),
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = switch (widget.block.kind) {
      LegalBlockKind.heading => textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      LegalBlockKind.quote => textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      _ => textTheme.bodyMedium,
    };

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          for (final run in widget.block.runs)
            TextSpan(
              text: run.text,
              recognizer: run.linkUrl == null
                  ? null
                  : _recognizerFor(run.linkUrl!),
              style: TextStyle(
                fontWeight: run.bold ? FontWeight.w700 : null,
                fontStyle: run.italic ? FontStyle.italic : null,
                color: run.linkUrl == null
                    ? null
                    : Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.combine([
                  if (run.underline || run.linkUrl != null)
                    TextDecoration.underline,
                  if (run.strikethrough) TextDecoration.lineThrough,
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
