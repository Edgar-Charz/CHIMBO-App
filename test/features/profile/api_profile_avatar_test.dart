import 'dart:io';

import 'package:chimbo/features/profile/data/api_profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

Map<String, Object?> _profile({String? avatarUrl}) => {
  'user_id': 5,
  'user_phone': '+255712345678',
  'user_full_name': 'Joyce Joseph',
  'user_avatar_url': avatarUrl,
  'business': null,
};

void main() {
  test('a new photo is sent as the "avatar" file field', () async {
    final folder = Directory.systemTemp.createTempSync('avatar_test');
    addTearDown(() => folder.deleteSync(recursive: true));
    final photo = File('${folder.path}/me.jpg')..writeAsBytesSync([1, 2, 3]);
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': _profile(avatarUrl: 'http://api.test/avatars/5.webp'),
      }),
    );

    final profile = await ApiProfileRepository(client).uploadAvatar(photo.path);

    expect(adapter.lastRequest!.uri.path, endsWith('/me/avatar'));
    final form = adapter.lastRequest!.data as FormData;
    expect(form.files.single.key, 'avatar');
    expect(profile.user.avatarUrl, 'http://api.test/avatars/5.webp');
  });

  test('removing the photo brings initials back', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({'success': true, 'data': _profile()}),
    );

    final profile = await ApiProfileRepository(client).deleteAvatar();

    expect(adapter.lastRequest!.method, 'DELETE');
    expect(profile.user.avatarUrl, isNull);
  });
}
