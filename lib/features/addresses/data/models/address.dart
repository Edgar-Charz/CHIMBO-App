/// A delivery address. JSON keys follow the `addresses` table columns, plus the joined
/// region/district names the API adds for display.
class Address {
  const Address({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.regionId,
    required this.regionName,
    required this.street,
    this.districtId,
    this.districtName,
    this.landmark,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      // The copy inside an order has no id (it is not a saved address).
      id: json['address_id'] as int? ?? 0,
      recipientName: json['address_recipient_name'] as String,
      phone: json['address_phone'] as String,
      regionId: json['region_id'] as int,
      regionName: json['region_name'] as String,
      districtId: json['district_id'] as int?,
      districtName: json['district_name'] as String?,
      street: json['address_street'] as String,
      landmark: json['address_landmark'] as String?,
      isDefault: json['address_is_default'] as bool? ?? false,
    );
  }

  final int id;
  final String recipientName;

  /// `+255XXXXXXXXX`.
  final String phone;
  final int regionId;
  final String regionName;
  final int? districtId;
  final String? districtName;

  /// "Kariakoo, Mtaa wa Lumumba".
  final String street;
  final String? landmark;
  final bool isDefault;

  /// "Kariakoo, Lumumba Street, Ilala, Dar es Salaam".
  String get fullLocation =>
      [street, ?landmark, ?districtName, regionName].join(', ');

  Map<String, dynamic> toJson() => {
    'address_id': id,
    'address_recipient_name': recipientName,
    'address_phone': phone,
    'region_id': regionId,
    'region_name': regionName,
    'district_id': districtId,
    'district_name': districtName,
    'address_street': street,
    'address_landmark': landmark,
    'address_is_default': isDefault,
  };
}

/// What the address form sends (`POST /addresses`).
class AddressInput {
  const AddressInput({
    required this.recipientName,
    required this.phone,
    required this.regionId,
    required this.street,
    this.districtId,
    this.landmark,
  });

  final String recipientName;
  final String phone;
  final int regionId;
  final int? districtId;
  final String street;
  final String? landmark;

  /// Body of `POST /addresses` (the server makes the first address the default).
  Map<String, dynamic> toJson() => {
    'address_recipient_name': recipientName,
    'address_phone': phone,
    'region_id': regionId,
    'district_id': districtId,
    'address_street': street,
    'address_landmark': landmark,
  };
}
