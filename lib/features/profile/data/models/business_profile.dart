/// The customer's shop details. JSON keys are the `business_profiles` columns plus the joined
/// region/district names the API adds for display.
class BusinessProfile {
  const BusinessProfile({
    required this.regionId,
    required this.regionName,
    this.businessName,
    this.districtId,
    this.districtName,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      businessName: json['business_name'] as String?,
      regionId: json['region_id'] as int,
      regionName: json['region_name'] as String,
      districtId: json['district_id'] as int?,
      districtName: json['district_name'] as String?,
    );
  }

  final String? businessName;
  final int regionId;
  final String regionName;
  final int? districtId;
  final String? districtName;

  Map<String, dynamic> toJson() => {
    'business_name': businessName,
    'region_id': regionId,
    'region_name': regionName,
    'district_id': districtId,
    'district_name': districtName,
  };
}
