import 'package:chimbo/features/profile/data/models/business_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> businessJson(String status) => {
    'business_name': 'Duka la Joyce',
    'region_id': 2,
    'region_name': 'Dar es Salaam',
    'district_id': null,
    'district_name': null,
    'business_verification_status': status,
  };

  test('only a "verified" business shows the badge', () {
    expect(
      BusinessProfile.fromJson(businessJson('verified')).isVerified,
      isTrue,
    );
    for (final status in ['unverified', 'pending', 'rejected']) {
      expect(
        BusinessProfile.fromJson(businessJson(status)).isVerified,
        isFalse,
      );
    }
  });

  test('the saved copy keeps the verification', () {
    final business = BusinessProfile.fromJson(businessJson('verified'));

    expect(BusinessProfile.fromJson(business.toJson()).isVerified, isTrue);
  });
}
