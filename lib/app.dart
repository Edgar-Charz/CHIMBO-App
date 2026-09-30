import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/l10n/locale_provider.dart';
import 'package:chimbo/core/router/app_router.dart';
import 'package:chimbo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: theme, language and navigation.
class ChimboApp extends ConsumerWidget {
  const ChimboApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
      locale: ref.watch(appLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
    );
  }
}
