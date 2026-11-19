/// One product the customer asked CHIMBO staff to find.
class ProductRequest {
  const ProductRequest({
    required this.id,
    required this.description,
    required this.status,
    this.matchedProductId,
    this.matchedProductName,
    this.referenceImageUrl,
    this.matchedProductImageUrl,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    return ProductRequest(
      id: int.parse(json['product_request_id'].toString()),
      description: json['product_request_description'] as String,
      status: json['product_request_status'] as String,
      matchedProductId: json['matched_product_id'] == null
          ? null
          : int.tryParse(json['matched_product_id'].toString()),
      matchedProductName: json['matched_product_name'] as String?,
      referenceImageUrl: json['product_request_image_url'] as String?,
      matchedProductImageUrl: json['matched_product_image_url'] as String?,
    );
  }

  final int id;
  final String description;
  final String status;
  final int? matchedProductId;
  final String? matchedProductName;
  final String? referenceImageUrl;
  final String? matchedProductImageUrl;

  bool get canCancel => status == 'pending' || status == 'matched';
}
