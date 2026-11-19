import 'package:chimbo/features/catalog/data/models/product_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("maps the customer's reference photo and the matched product image", () {
    final request = ProductRequest.fromJson({
      'product_request_id': 14,
      'product_request_description': 'Gold necklace',
      'product_request_status': 'matched',
      'matched_product_id': 29,
      'matched_product_name': 'Gold Plated Necklace',
      'product_request_image_url': 'https://shop.example/request-photo',
      'matched_product_image_url': 'https://shop.example/catalog-photo.webp',
    });

    expect(request.referenceImageUrl, 'https://shop.example/request-photo');
    expect(
      request.matchedProductImageUrl,
      'https://shop.example/catalog-photo.webp',
    );
    expect(request.canCancel, isTrue);
  });

  test('keeps old requests valid when they have no photos', () {
    final request = ProductRequest.fromJson({
      'product_request_id': 15,
      'product_request_description': 'Silver ring',
      'product_request_status': 'notified',
      'matched_product_id': null,
      'matched_product_name': null,
    });

    expect(request.referenceImageUrl, isNull);
    expect(request.matchedProductImageUrl, isNull);
    expect(request.canCancel, isFalse);
  });
}
