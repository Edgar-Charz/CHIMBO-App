/// The logged-in customer. JSON keys are the `users` table columns.
class AppUser {
  const AppUser({required this.id, required this.phone, this.fullName});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'] as int,
      phone: json['user_phone'] as String,
      fullName: json['user_full_name'] as String?,
    );
  }

  final int id;

  /// Always `+255XXXXXXXXX`.
  final String phone;

  /// Null until registration step 3 is done.
  final String? fullName;

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'user_phone': phone,
    'user_full_name': fullName,
  };

  AppUser copyWith({String? fullName}) {
    return AppUser(id: id, phone: phone, fullName: fullName ?? this.fullName);
  }
}
