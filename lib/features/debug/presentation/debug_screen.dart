import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/section_header.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/debug/presentation/widgets/health_card.dart';
import 'package:chimbo/features/debug/presentation/widgets/ui_kit_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Developer tools (debug builds only): API health, a UI kit preview and logout (to test the
/// login flow again).
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.debugTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionHeader(title: l10n.debugServerSection),
          const HealthCard(),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: l10n.debugUiKitSection),
          const UiKitPreview(),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.actionLogout,
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.outlined,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
