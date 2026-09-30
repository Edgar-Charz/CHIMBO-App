/// A product category (Cosmetics, Jewelry) or one of its sub-categories (chips).
/// JSON keys follow the `categories` table columns.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.tagline,
    this.imageUrl,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final children = json['children'] as List<dynamic>? ?? const [];
    return Category(
      id: json['category_id'] as int,
      name: json['category_name'] as String,
      tagline: json['category_tagline'] as String?,
      imageUrl: json['category_image_url'] as String?,
      children: children
          .map((child) => Category.fromJson(child as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;

  /// "Shamba la Vipodozi" under Cosmetics.
  final String? tagline;

  /// Admin-uploaded image used for the category card on Home.
  final String? imageUrl;

  /// Sub-categories shown as chips.
  final List<Category> children;

  Map<String, dynamic> toJson() => {
    'category_id': id,
    'category_name': name,
    'category_tagline': tagline,
    'category_image_url': imageUrl,
    'children': children.map((child) => child.toJson()).toList(),
  };
}
