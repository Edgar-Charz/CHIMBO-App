import 'dart:convert';

import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/auth/data/api_auth_repository.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/auth/data/models/login_start.dart';
import 'package:chimbo/features/auth/data/models/pin_input.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

// A profile object as the API sends it (docs/API_REFERENCE.md).
const Map<String, Object?> _profile = {
  'user_id': 1,
  'user_phone': '+255712000111',
  'user_full_name': 'Joyce Joseph',
  'user_email': null,
  'user_avatar_url': null,
  'user_locale': 'sw',
  'created_at': '2026-09-28T14:39:44+00:00',
  'user_has_pin': true,
  'business': {
    'business_name': 'Duka la Joyce',
    'region_id': 2,
    'region_name': 'Dar es Salaam',
    'district_id': 8,
    'district_name': 'Ilala',
    'business_verification_status': 'unverified',
  },
  'is_profile_complete': true,
};

void main() {
  const tokenStorage = TokenStorage(FlutterSecureStorage());

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'OTP request sends the phone and reads timings and the test code',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': {
            'user_phone': '+255712000111',
            'otp_expires_in_seconds': 300,
            'otp_resend_after_seconds': 60,
            'debug_otp_code': '849144',
          },
        }),
      );
      final repository = ApiAuthRepository(
        apiClient: client,
        tokenStorage: tokenStorage,
      );

      final result = await repository.requestOtp('0712 000 111');

      expect(adapter.lastRequest!.uri.path, endsWith('/auth/otp/request'));
      expect(adapter.lastRequest!.data, {'user_phone': '0712 000 111'});
      expect(result.resendAfter, const Duration(seconds: 60));
      expect(result.debugCode, '849144');
    },
  );

  test('verifying saves the token and returns the session', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'user': _profile,
          'auth_token': 'b27acdb',
          'auth_token_expires_at': '2026-11-27T14:39:44+00:00',
        },
      }),
    );
    final repository = ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
      readDeviceName: () async => 'Tecno Spark 10',
    );

    final session = await repository.verifyOtp(
      phone: '+255712000111',
      code: '849144',
    );

    final sent = adapter.lastRequest!.data as Map<String, Object?>;
    expect(sent['client'], 'app');
    expect(sent['otp_code'], '849144');
    expect(await tokenStorage.readToken(), 'b27acdb');
    expect(session.user.fullName, 'Joyce Joseph');
    expect(session.hasPin, isTrue);
    expect(session.isProfileComplete, isTrue);
  });

  test('the phone screen learns which step comes next', () async {
    Future<LoginStart> startWith(Map<String, Object?> data) async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({'success': true, 'data': data}),
      );
      final start = await ApiAuthRepository(
        apiClient: client,
        tokenStorage: tokenStorage,
      ).startLogin('0712 000 111');
      expect(adapter.lastRequest!.uri.path, endsWith('/auth/start'));
      expect(adapter.lastRequest!.data, {'user_phone': '0712 000 111'});
      return start;
    }

    final pin = await startWith({
      'user_phone': '+255712000111',
      'next_step': 'pin',
    });
    expect(pin.nextStep, LoginNextStep.pin);
    expect(pin.otp, isNull);

    final locked = await startWith({
      'user_phone': '+255712000111',
      'next_step': 'pin_locked',
    });
    expect(locked.nextStep, LoginNextStep.pinLocked);

    // A new number: the code is already sent, with the usual timings.
    final otp = await startWith({
      'next_step': 'otp',
      'user_phone': '+255712000111',
      'otp_expires_in_seconds': 300,
      'otp_resend_after_seconds': 60,
      'debug_otp_code': '849144',
    });
    expect(otp.nextStep, LoginNextStep.otp);
    expect(otp.otp?.debugCode, '849144');
  });

  test('PIN login sends the PIN as text and saves the token', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {'user': _profile, 'auth_token': 'pin-token'},
      }),
    );

    await ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
      readDeviceName: () async => 'Tecno Spark 10',
    ).loginWithPin(phone: '+255712000111', pin: '0482');

    expect(adapter.lastRequest!.uri.path, endsWith('/auth/pin/login'));
    final sent = adapter.lastRequest!.data as Map<String, Object?>;
    // Text, so the leading zero survives.
    expect(sent['user_pin'], '0482');
    expect(sent['user_phone'], '+255712000111');
    expect(sent['client'], 'app');
    expect(sent['auth_token_platform'], 'android');
    expect(sent['auth_token_device_name'], 'Tecno Spark 10');
    expect(await tokenStorage.readToken(), 'pin-token');
  });

  test('a new PIN sends no current PIN; Badilisha PIN does', () async {
    await tokenStorage.saveToken('b27acdb');
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': _profile}),
    );
    final repository = ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
      readDeviceName: () async => 'Tecno Spark 10',
    );

    await repository.savePin(const PinInput(pin: '4826', confirmation: '4826'));
    expect(adapter.lastRequest!.uri.path, endsWith('/auth/pin'));
    expect(adapter.lastRequest!.data, {
      'user_pin': '4826',
      'user_pin_confirmation': '4826',
    });

    final session = await repository.savePin(
      const PinInput(pin: '4826', confirmation: '4826', currentPin: '0593'),
    );
    expect(adapter.lastRequest!.data, {
      'user_pin': '4826',
      'user_pin_confirmation': '4826',
      'current_pin': '0593',
    });
    expect(session.token, 'b27acdb');
  });

  test('business details send the API field names', () async {
    await tokenStorage.saveToken('b27acdb');
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': _profile}),
    );

    await ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
    ).completeProfile(
      const BusinessProfileInput(
        fullName: 'Joyce Joseph',
        regionId: 2,
        districtId: 8,
      ),
    );

    expect(adapter.lastRequest!.uri.path, endsWith('/auth/profile'));
    expect(adapter.lastRequest!.data, {
      'user_full_name': 'Joyce Joseph',
      'business_name': null,
      'region_id': 2,
      'district_id': 8,
    });
  });

  test('an expired token logs out quietly at start-up', () async {
    await tokenStorage.saveToken('old');
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': false,
        'error': {'code': 'UNAUTHENTICATED', 'message': 'Tafadhali ingia.'},
      }, statusCode: 401),
    );

    final session = await ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
    ).restoreSession();

    expect(session, isNull);
    expect(await tokenStorage.readToken(), isNull);
  });

  test('logout forgets the token even when the server call fails', () async {
    await tokenStorage.saveToken('b27acdb');
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': false,
        'error': {'code': 'SERVER_ERROR', 'message': 'Hitilafu.'},
      }, statusCode: 500),
    );

    await ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
    ).logout();

    expect(await tokenStorage.readToken(), isNull);
  });

  test('delete account confirms and forgets the token', () async {
    await tokenStorage.saveToken('b27acdb');
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': null}),
    );

    await ApiAuthRepository(
      apiClient: client,
      tokenStorage: tokenStorage,
    ).deleteAccount();

    expect(adapter.lastRequest!.method, 'DELETE');
    expect(jsonEncode(adapter.lastRequest!.data), '{"confirm":true}');
    expect(await tokenStorage.readToken(), isNull);
  });
}
