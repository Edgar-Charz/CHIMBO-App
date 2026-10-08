import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:chimbo/features/catalog/data/models/product_summary.dart';

/// An active Home banner maintained in the admin dashboard.
class HomeBanner {
  const HomeBanner({
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.imageUrl,
    this.targetType,
    this.targetValue,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) => HomeBanner(
    title: json['banner_title'] as String? ?? '',
    subtitle: json['banner_subtitle'] as String?,
    buttonLabel: json['banner_button_label'] as String?,
    imageUrl: json['banner_image_url'] as String?,
    targetType: json['banner_target_type'] as String?,
    targetValue: json['banner_target_value']?.toString(),
  );

  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final String? imageUrl;
  final String? targetType;
  final String? targetValue;
}

/// Everything Home shows, from one `GET /home` call (blueprint §6.5: Home in one request).
class HomeData {
  const HomeData({
    required this.topCategories,
    required this.bestSellers,
    required this.recentlyOrdered,
    this.banners = const [],
    this.deals = const [],
    this.offers = const [],
    this.newArrivals = const [],
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<ProductSummary> products(String key) =>
        (json[key] as List<dynamic>? ?? const [])
            .map(
              (item) => ProductSummary.fromJson(item as Map<String, dynamic>),
            )
            .toList();
    final banners = json['banners'] as List<dynamic>? ?? const [];
    return HomeData(
      topCategories: (json['top_categories'] as List<dynamic>? ?? const [])
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
      banners: banners
          .map((item) => HomeBanner.fromJson(item as Map<String, dynamic>))
          .toList(),
      deals: products('deals'),
      offers: products('offers'),
      newArrivals: products('new_arrivals'),
      bestSellers: products('best_sellers'),
      recentlyOrdered: products('recently_ordered'),
    );
  }

  final List<Category> topCategories;
  final List<HomeBanner> banners;
  final List<ProductSummary> deals;

  /// "Ofa za muda": running offers, ending soonest first (the rail hides when empty).
  final List<ProductSummary> offers;
  final List<ProductSummary> newArrivals;
  final List<ProductSummary> bestSellers;

  /// Empty for a customer who hasn't ordered yet (the rail is then hidden).
  final List<ProductSummary> recentlyOrdered;
}
