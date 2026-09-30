import 'dart:convert';

import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory stand-in for the server's per-customer data, used by the fake repositories (cart,
/// addresses, wishlist, orders). Each customer gets their own data.
class FakeCustomerStore {
  const FakeCustomerStore({
    required this._preferences,
    required this._currentUserId,
  });

  final SharedPreferences _preferences;

  /// The logged-in customer's id, or null when logged out.
  final int? Function() _currentUserId;

  Future<Object?> read(String name) async {
    final stored = _preferences.getString(_key(name));
    return stored == null ? null : jsonDecode(stored);
  }

  Future<void> write(String name, Object? data) async {
    await _preferences.setString(_key(name), jsonEncode(data));
  }

  /// A logged-out read or write fails like the server would (`401`).
  String _key(String name) {
    final userId = _currentUserId();
    if (userId == null) {
      throw const ApiException(code: ApiErrorCode.unauthenticated);
    }
    return 'dev_${name}_user_$userId';
  }
}

final fakeCustomerStoreProvider = Provider<FakeCustomerStore>(
  (ref) => FakeCustomerStore(
    preferences: ref.watch(sharedPreferencesProvider),
    currentUserId: () => ref.read(authControllerProvider).user?.id,
  ),
);
