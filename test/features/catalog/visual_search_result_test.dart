import 'package:chimbo/features/catalog/data/models/visual_search_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisualSearchResult', () {
    test('parses detected status, query, and items from json', () {
      final json = {
        'detected': {'search_query': 'Nivea Body Lotion', 'is_ai_active': true},
        'items': [
          {
            'product_id': 1,
            'product_name': 'Nivea Rich Nourishing 400ml',
            'product_slug': 'nivea-rich-nourishing-400ml',
            'category_id': 4,
            'product_price': 12000,
            'product_price_from': 11000,
            'product_moq': 6,
            'seller_name': 'Vipodozi Wholesale',
            'seller_is_verified': true,
            'product_in_stock': true,
          },
        ],
      };

      final result = VisualSearchResult.fromJson(json);

      expect(result.detectedQuery, 'Nivea Body Lotion');
      expect(result.isAiActive, isTrue);
      expect(result.items.length, 1);
      expect(result.items.first.id, 1);
      expect(result.items.first.name, 'Nivea Rich Nourishing 400ml');
    });

    test('parses when image recognition is unavailable', () {
      final result = VisualSearchResult.fromJson({
        'detected': {'is_ai_active': false},
      });

      expect(result.isAiActive, isFalse);
      expect(result.items, isEmpty);
    });

    test('handles missing or empty detected and items gracefully', () {
      final result = VisualSearchResult.fromJson(const {});

      expect(result.detectedQuery, '');
      expect(result.isAiActive, isNull);
      expect(result.items, isEmpty);
    });
  });
}
