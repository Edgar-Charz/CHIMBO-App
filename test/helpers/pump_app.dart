import 'package:chimbo/app.dart';
import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/addresses/data/address_repository.dart';
import 'package:chimbo/features/app_images/data/app_images_providers.dart';
import 'package:chimbo/features/app_images/data/app_images_repository.dart';
import 'package:chimbo/features/auth/data/auth_repository.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';
import 'package:chimbo/features/cart/data/cart_repository.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/checkout/data/checkout_repository.dart';
import 'package:chimbo/features/locations/data/location_repository.dart';
import 'package:chimbo/features/notifications/data/notifications_repository.dart';
import 'package:chimbo/features/onboarding/presentation/splash_screen.dart';
import 'package:chimbo/features/orders/data/orders_repository.dart';
import 'package:chimbo/features/payments/data/payments_repository.dart';
import 'package:chimbo/features/profile/data/profile_repository.dart';
import 'package:chimbo/features/support/data/support_repository.dart';
import 'package:chimbo/features/wishlist/data/wishlist_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_account_store.dart';
import 'fake_address_repository.dart';
import 'fake_app_images_repository.dart';
import 'fake_auth_repository.dart';
import 'fake_cart_repository.dart';
import 'fake_catalog_repository.dart';
import 'fake_checkout_repository.dart';
import 'fake_customer_store.dart';
import 'fake_location_repository.dart';
import 'fake_notifications_repository.dart';
import 'fake_orders_repository.dart';
import 'fake_payments_repository.dart';
import 'fake_profile_repository.dart';
import 'fake_support_repository.dart';
import 'fake_wishlist_repository.dart';

const String testPhone = '+255712345678';

/// The PIN of the [testPhone] account.
const String testPin = '4826';

/// Starts the whole app with in-memory storage and fake server repositories (tests never call
/// the real API); the splash is showing afterwards. [isLoggedIn] registers [testPhone] first,
/// like a customer who finished registration on an earlier launch; [hasAccount] registers it
/// and logs out again (the next login uses [testPin]). Returns the preferences to check what
/// was saved.
Future<SharedPreferences> pumpApp(
  WidgetTester tester, {
  bool hasSeenOnboarding = false,
  bool isLoggedIn = false,
  bool hasAccount = false,
  AppImagesRepository? appImagesRepository,
}) async {
  // A phone-sized screen (360 × 800), so layouts are tested at a realistic size.
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    if (hasSeenOnboarding) 'onboarding_seen': true,
  });
  FlutterSecureStorage.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final accounts = FakeAccountStore(
    tokenStorage: const TokenStorage(FlutterSecureStorage()),
    preferences: preferences,
  );
  if (isLoggedIn || hasAccount) {
    await _registerTestCustomer(accounts);
  }
  if (hasAccount && !isLoggedIn) {
    await accounts.signOut();
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appImagesRepositoryProvider.overrideWithValue(
          appImagesRepository ?? FakeAppImagesRepository(),
        ),
        catalogRepositoryProvider.overrideWithValue(
          const FakeCatalogRepository(),
        ),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(accounts)),
        profileRepositoryProvider.overrideWithValue(
          FakeProfileRepository(accounts),
        ),
        supportRepositoryProvider.overrideWithValue(
          const FakeSupportRepository(),
        ),
        paymentsRepositoryProvider.overrideWithValue(FakePaymentsRepository()),
        locationRepositoryProvider.overrideWithValue(
          const FakeLocationRepository(),
        ),
        cartRepositoryProvider.overrideWith(
          (ref) => FakeCartRepository(
            store: ref.watch(fakeCustomerStoreProvider),
            catalog: ref.watch(catalogRepositoryProvider),
          ),
        ),
        addressRepositoryProvider.overrideWith(
          (ref) => FakeAddressRepository(
            store: ref.watch(fakeCustomerStoreProvider),
            locations: ref.watch(locationRepositoryProvider),
          ),
        ),
        checkoutRepositoryProvider.overrideWith(
          (ref) => FakeCheckoutRepository(ref.watch(cartRepositoryProvider)),
        ),
        notificationsRepositoryProvider.overrideWith(
          (ref) => FakeNotificationsRepository(),
        ),
        ordersRepositoryProvider.overrideWith(
          (ref) => FakeOrdersRepository(
            store: ref.watch(fakeCustomerStoreProvider),
            cartRepository: ref.watch(cartRepositoryProvider),
            addressRepository: ref.watch(addressRepositoryProvider),
            catalog: ref.watch(catalogRepositoryProvider),
            profileRepository: ref.watch(profileRepositoryProvider),
            checkout: ref.watch(checkoutRepositoryProvider),
          ),
        ),
        wishlistRepositoryProvider.overrideWith(
          (ref) => FakeWishlistRepository(
            store: ref.watch(fakeCustomerStoreProvider),
            catalog: ref.watch(catalogRepositoryProvider),
          ),
        ),
      ],
      child: const ChimboApp(),
    ),
  );
  return preferences;
}

/// Like [pumpApp], then waits until the splash has moved on.
Future<SharedPreferences> pumpAppPastSplash(
  WidgetTester tester, {
  bool hasSeenOnboarding = false,
  bool isLoggedIn = false,
  bool hasAccount = false,
  AppImagesRepository? appImagesRepository,
}) async {
  final preferences = await pumpApp(
    tester,
    hasSeenOnboarding: hasSeenOnboarding,
    isLoggedIn: isLoggedIn,
    hasAccount: hasAccount,
    appImagesRepository: appImagesRepository,
  );
  await tester.pump(SplashScreen.displayTime);
  await tester.pumpAndSettle();
  return preferences;
}

Future<void> _registerTestCustomer(FakeAccountStore accounts) async {
  final repository = FakeAuthRepository(accounts);
  await repository.verifyOtp(phone: testPhone, code: '123456');
  await repository.savePin(const PinInput(pin: testPin, confirmation: testPin));
  await repository.completeProfile(
    const BusinessProfileInput(fullName: 'Joyce Joseph', regionId: 1),
  );
}
