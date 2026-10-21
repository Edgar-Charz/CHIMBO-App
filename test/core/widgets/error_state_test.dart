import 'package:chimbo/core/l10n/app_localizations.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('retry shows a loading indicator and localized progress label', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ErrorState(
            error: Exception('network'),
            onRetry: () => retryCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Jaribu tena'));
    await tester.pump();

    expect(retryCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Inapakia...'), findsOneWidget);
  });
}
