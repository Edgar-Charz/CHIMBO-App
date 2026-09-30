/// What registration step 3 sends (`POST /auth/profile`).
class BusinessProfileInput {
  const BusinessProfileInput({
    required this.fullName,
    required this.regionId,
    this.businessName,
    this.districtId,
  });

  final String fullName;
  final int regionId;

  /// Optional ("Si lazima").
  final String? businessName;
  final int? districtId;

  /// Body of `POST /auth/profile` (docs/API_REFERENCE.md).
  Map<String, dynamic> toJson() => {
    'user_full_name': fullName,
    'business_name': businessName,
    'region_id': regionId,
    'district_id': districtId,
  };
}
