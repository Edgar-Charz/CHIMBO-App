import 'dart:async';

import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/home/data/home_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('home retry shows progress until data loads', (tester) async {
    final catalog = _RetryingCatalogRepository();
    await pumpAppPastSplash(
      tester,
      hasSeenOnboarding: true,
      isLoggedIn: true,
      catalogRepository: catalog,
    );
    await tester.pumpAndSettle();

    expect(catalog.homeRequests, 1);
    expect(
      find.text('Hakuna mtandao. Angalia intaneti yako kisha ujaribu tena.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Jaribu tena'));
    await tester.pump();
    expect(catalog.homeRequests, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Inapakia duka...'), findsOneWidget);

    catalog.retryCompleter.complete();
    await tester.pumpAndSettle();

    expect(
      find.text('Hakuna mtandao. Angalia intaneti yako kisha ujaribu tena.'),
      findsNothing,
    );
    expect(find.text('COSMETICS'), findsOneWidget);
  });
}

class _RetryingCatalogRepository extends FakeCatalogRepository {
  final Completer<void> retryCompleter = Completer<void>();
  int _homeRequests = 0;

  int get homeRequests => _homeRequests;

  @override
  Future<HomeData> getHome() async {
    _homeRequests++;
    if (_homeRequests == 1) {
      throw const ApiException(code: ApiErrorCode.network);
    }
    await retryCompleter.future;
    return super.getHome();
  }
}
