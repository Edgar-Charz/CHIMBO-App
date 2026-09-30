import 'package:chimbo/features/locations/data/api_location_repository.dart';
import 'package:chimbo/features/profile/data/api_profile_repository.dart';
import 'package:chimbo/features/wishlist/data/api_wishlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  group('wishlist', () {
    test('ids come from /wishlist/ids', () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': [7, 1],
        }),
      );

      final ids = await ApiWishlistRepository(client).getSavedIds();

      expect(adapter.lastRequest!.uri.path, endsWith('/wishlist/ids'));
      expect(ids, {7, 1});
    });

    test('save posts the product id; remove deletes by id', () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({'success': true, 'data': null}),
      );
      final repository = ApiWishlistRepository(client);

      await repository.save(7);
      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.data, {'product_id': 7});

      await repository.remove(7);
      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.uri.path, endsWith('/wishlist/7'));
    });
  });

  test('districts get their region id from the URL', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [
          {'district_id': 8, 'district_name': 'Ilala'},
        ],
      }),
    );

    final districts = await ApiLocationRepository(client).getDistricts(2);

    expect(districts.single.name, 'Ilala');
    expect(districts.single.regionId, 2);
  });

  test('profile reads the flat API profile object', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'user_id': 1,
          'user_phone': '+255712000111',
          'user_full_name': 'Joyce Joseph',
          'business': {
            'business_name': null,
            'region_id': 2,
            'region_name': 'Dar es Salaam',
            'district_id': null,
            'district_name': null,
          },
          'is_profile_complete': true,
        },
      }),
    );

    final profile = await ApiProfileRepository(client).getProfile();

    expect(profile.user.fullName, 'Joyce Joseph');
    expect(profile.business?.regionName, 'Dar es Salaam');
  });
}
