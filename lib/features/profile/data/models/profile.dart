import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/profile/data/models/business_profile.dart';

/// What Wasifu shows (`GET /me`): the customer and their shop. JSON = the API's profile object:
/// the `user_*` keys at the top level plus `business` (null until registration step 3).
class Profile {
  const Profile({required this.user, this.business});

  factory Profile.fromJson(Map<String, dynamic> json) {
    final business = json['business'];
    return Profile(
      user: AppUser.fromJson(json),
      business: business == null
          ? null
          : BusinessProfile.fromJson(business as Map<String, dynamic>),
    );
  }

  final AppUser user;

  /// Null only before registration step 3.
  final BusinessProfile? business;

  Map<String, dynamic> toJson() => {
    ...user.toJson(),
    'business': business?.toJson(),
  };

  Profile copyWith({AppUser? user, BusinessProfile? business}) {
    return Profile(
      user: user ?? this.user,
      business: business ?? this.business,
    );
  }
}
