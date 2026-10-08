import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/core/widgets/section_card.dart';
import 'package:chimbo/features/support/application/support_providers.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wasifu → Msaada: when support answers, a call button and a WhatsApp button.
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(supportContactsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.menuHelp)),
      body: contacts.when(
        data: (value) => _HelpContent(contacts: value),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(supportContactsProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _HelpContent extends StatelessWidget {
  const _HelpContent({required this.contacts});

  final SupportContacts contacts;

  /// Opens the phone's dialer or WhatsApp; says so when the phone has no app for it.
  Future<void> _open(BuildContext context, Uri uri) async {
    final toast = AppToast.of(context);
    final message = context.l10n.helpCannotOpen;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      toast.error(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.helpIntro, style: textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          title: l10n.helpHoursTitle,
          child: Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: AppSizes.iconMedium,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(contacts.hours, style: textTheme.bodyMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.helpCall(TzPhone.format(contacts.phone)),
          icon: Icons.call_outlined,
          onPressed: () =>
              _open(context, Uri(scheme: 'tel', path: contacts.phone)),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.helpWhatsapp,
          icon: Icons.chat_outlined,
          variant: AppButtonVariant.outlined,
          onPressed: () => _open(context, Uri.parse(contacts.whatsappUrl)),
        ),
      ],
    );
  }
}
