/// One product photo in the three sizes the server makes (WebP), so each place downloads only
/// what it needs: thumb (~300 px) for the thumbnail strip, medium (~800 px) for the big photo,
/// large (~1600 px) for zoom. JSON = one `gallery` item of `GET /products/{id}`.
class ProductPhoto {
  const ProductPhoto({
    required this.thumbUrl,
    required this.mediumUrl,
    required this.largeUrl,
  });

  factory ProductPhoto.fromJson(Map<String, dynamic> json) {
    return ProductPhoto(
      thumbUrl: json['product_image_thumb_url'] as String,
      mediumUrl: json['product_image_medium_url'] as String,
      largeUrl: json['product_image_large_url'] as String,
    );
  }

  /// When only one size is known (the `images` list), every place uses it.
  const ProductPhoto.singleSize(String url)
    : thumbUrl = url,
      mediumUrl = url,
      largeUrl = url;

  final String thumbUrl;
  final String mediumUrl;
  final String largeUrl;

  Map<String, dynamic> toJson() => {
    'product_image_thumb_url': thumbUrl,
    'product_image_medium_url': mediumUrl,
    'product_image_large_url': largeUrl,
  };
}
