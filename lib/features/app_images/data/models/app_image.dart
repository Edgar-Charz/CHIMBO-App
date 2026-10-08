import 'package:chimbo/features/app_images/data/models/app_image_slot.dart';

/// One admin-managed picture for a fixed app screen.
class AppImage {
  const AppImage({
    required this.slot,
    required this.url,
    required this.updatedAt,
  });

  factory AppImage.fromJson(Map<String, dynamic> json) => AppImage(
    slot: AppImageSlot.fromApiValue(json['app_image_slot'] as String? ?? ''),
    url: json['app_image_url'] as String? ?? '',
    updatedAt: json['updated_at'] as String? ?? '',
  );

  final AppImageSlot? slot;
  final String url;
  final String updatedAt;

  Map<String, Object?> toJson() => {
    'app_image_slot': slot?.apiValue,
    'app_image_url': url,
    'updated_at': updatedAt,
  };

  @override
  bool operator ==(Object other) =>
      other is AppImage &&
      other.slot == slot &&
      other.url == url &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(slot, url, updatedAt);
}
