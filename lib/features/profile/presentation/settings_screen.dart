import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/confirm_dialog.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/debug/presentation/open_debug_tools_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mipangilio: language (Kiswahili only for now) and account deletion.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteAccountConfirmTitle,
      message: l10n.deleteAccountConfirmMessage,
      confirmLabel: l10n.actionDelete,
      isDestructive: true,
    );
    if (!confirmed) {
      return;
    }
    try {
      // The router moves to the phone screen once the state changes.
      await ref.read(authControllerProvider.notifier).deleteAccount();
    } on ApiException catch (error) {
      if (context.mounted) {
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuSettings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionHeader(title: l10n.settingsLanguage),
          const _LanguageCard(),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: l10n.settingsAccount),
          Card(
            child: ListTile(
              onTap: () => _confirmDelete(context, ref),
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: Text(
                l10n.deleteAccount,
                style: const TextStyle(color: AppColors.danger),
              ),
              subtitle: Text(l10n.deleteAccountHint),
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
            const OpenDebugToolsButton(),
          ],
        ],
      ),
    );
  }
}

/// Kiswahili is the only language for now; English is shown as coming (agreed placeholder).
class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.languageSwahili),
            trailing: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
            ),
          ),
          const Divider(height: AppSizes.borderWidth),
          ListTile(
            enabled: false,
            title: Text(l10n.languageEnglish),
            trailing: Text(l10n.comingSoonShort),
          ),
        ],
      ),
    );
  }
}
