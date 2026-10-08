import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';
import 'package:chimbo/features/auth/presentation/widgets/pin_setup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wasifu → "Badilisha PIN": current PIN, new PIN, new PIN again. Other phones on the account
/// are logged out; this one stays logged in.
class ChangePinScreen extends ConsumerWidget {
  const ChangePinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    Future<void> changePin(PinInput input) async {
      final toast = AppToast.of(context);
      final router = GoRouter.of(context);
      await ref.read(authControllerProvider.notifier).savePin(input);
      toast.success(l10n.pinChanged);
      router.pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuChangePin)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.changePinNotice,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              PinSetupForm(
                askCurrentPin: true,
                submitLabel: l10n.menuChangePin,
                onSubmit: changePin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
