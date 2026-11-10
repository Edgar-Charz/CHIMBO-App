/// The logged-in customer. JSON keys are the `users` table columns.
class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    this.fullName,
    this.email,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'] as int,
      phone: json['user_phone'] as String,
      fullName: json['user_full_name'] as String?,
      email: json['user_email'] as String?,
      avatarUrl: json['user_avatar_url'] as String?,
    );
  }

  final int id;

  /// Always `+255XXXXXXXXX`.
  final String phone;

  /// Null until registration step 3 is done.
  final String? fullName;

  /// Optional email address saved on the account.
  final String? email;

  /// The profile photo (300 px); null → show initials.
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'user_phone': phone,
    'user_full_name': fullName,
    'user_email': email,
    'user_avatar_url': avatarUrl,
  };

  AppUser copyWith({String? fullName, String? email}) {
    return AppUser(
      id: id,
      phone: phone,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl,
    );
  }
}
