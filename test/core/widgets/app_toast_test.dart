import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows at the top, runs its action, hides by itself', (
    tester,
  ) async {
    var actionTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppToast.of(context).success(
              'Imeongezwa kikapuni.',
              actionLabel: 'Ona Kikapu',
              onAction: () => actionTapped = true,
            ),
            child: const Text('onyesha'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('onyesha'));
    await tester.pumpAndSettle();
    expect(find.text('Imeongezwa kikapuni.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Imeongezwa kikapuni.')).dy,
      lessThan(100),
    );

    await tester.tap(find.text('Ona Kikapu'));
    await tester.pumpAndSettle();
    expect(actionTapped, isTrue);
    expect(find.text('Imeongezwa kikapuni.'), findsNothing);

    // Without a tap it goes away after its few seconds.
    await tester.tap(find.text('onyesha'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Imeongezwa kikapuni.'), findsNothing);
  });
}
