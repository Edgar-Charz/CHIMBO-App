import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entry point to [DebugScreen]; only added to the UI in debug builds.
class OpenDebugToolsButton extends StatelessWidget {
  const OpenDebugToolsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.push(AppRoutes.debug),
      icon: const Icon(Icons.build_outlined),
      label: Text(context.l10n.debugOpenTools),
    );
  }
}
