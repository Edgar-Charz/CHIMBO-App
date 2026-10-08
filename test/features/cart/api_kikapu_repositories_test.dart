import 'package:chimbo/core/l10n/app_localizations_sw.dart';
import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/addresses/data/api_address_repository.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/cart/data/api_cart_repository.dart';
import 'package:chimbo/features/cart/data/models/cart.dart';
import 'package:chimbo/features/checkout/data/api_checkout_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

// Trimmed copy of a real `/cart` reply from the local API (2026-09-29).
Map<String, Object?> _cart({
  String? lineProblem,
  bool canCheckout = true,
  List<Object?> warnings = const [],
}) => {
  'groups': [
    {
      'category_name': 'Cosmetics',
      'items': [
        {
          'product': {
            'product_id': 1,
            'product_name': 'Vaseline Petroleum Jelly 400ml',
            'category_id': 2,
            'product_price': 5500,
            'product_price_from': 4500,
            'product_compare_at_price': 6000,
            'product_moq': 2,
            'product_in_stock': true,
            'product_image_url': null,
            'product_badge': 'deal',
            'seller_name': 'Shamba la Vipodozi',
            'seller_is_verified': true,
          },
          'cart_quantity': 8,
          'unit_price': 5000,
          'tier_min_quantity': 6,
          'line_total': 40000,
          'line_savings': 4000,
          'next_tier_hint': {'extra_quantity': 16, 'unit_price': 4700},
          'line_problem': lineProblem,
          'available_quantity': 180,
        },
      ],
    },
  ],
  'summary': {
    'line_count': 1,
    'piece_count': 8,
    'subtotal': 40000,
    'savings': 4000,
    'can_checkout': canCheckout,
  },
  'warnings': warnings,
};

void main() {
  test(
    'cart: adding sends only id and quantity, reads the priced cart',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({'success': true, 'data': _cart()}),
      );

      final cart = await ApiCartRepository(client).addItem(1, 8);

      expect(adapter.lastRequest!.uri.path, endsWith('/cart/items'));
      expect(adapter.lastRequest!.data, {'product_id': 1, 'quantity': 8});
      final line = cart.lines.single;
      expect(line.unitPrice, 5000);
      expect(line.lineSavings, 4000);
      expect(line.availableQuantity, 180);
      expect(line.problem, isNull);
      expect(cart.savings, 4000);
      expect(cart.canCheckout, isTrue);
    },
  );

  test(
    'cart: a line problem blocks checkout; warnings are kept to show',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': _cart(
            lineProblem: 'not_enough_stock',
            canCheckout: false,
            warnings: [
              'Bidhaa 1 imeondolewa kwa sababu haipo tena.',
              {'message': 'Nyingine imeondolewa.'},
            ],
          ),
        }),
      );

      final cart = await ApiCartRepository(client).setQuantity(1, 200);

      expect(adapter.lastRequest!.method, 'PATCH');
      expect(adapter.lastRequest!.uri.path, endsWith('/cart/items/1'));
      expect(cart.lines.single.problem, CartLineProblem.notEnoughStock);
      expect(cart.canCheckout, isFalse);
      expect(cart.warnings, hasLength(2));
    },
  );

  test(
    'errors show the server text: MOQ from the field, stock as-is',
    () async {
      final l10n = AppLocalizationsSw();
      final (moqClient, _) = clientReplying(
        (_) => jsonReply({
          'success': false,
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Tafadhali rekebisha taarifa zilizokosewa.',
            'fields': {'quantity': 'Kiwango cha chini cha kuagiza ni 2 (MOQ).'},
          },
        }, statusCode: 422),
      );
      final (stockClient, _) = clientReplying(
        (_) => jsonReply({
          'success': false,
          'error': {
            'code': 'OUT_OF_STOCK',
            'message':
                'Samahani, zimebaki 180 tu za Vaseline Petroleum Jelly 400ml.',
          },
        }, statusCode: 409),
      );

      Future<String> messageOf(Future<Object?> call) async {
        try {
          await call;
        } on ApiException catch (error) {
          return l10n.errorMessage(error);
        }
        fail('expected an ApiException');
      }

      expect(
        await messageOf(ApiCartRepository(moqClient).addItem(1, 1)),
        'Kiwango cha chini cha kuagiza ni 2 (MOQ).',
      );
      expect(
        await messageOf(ApiCartRepository(stockClient).addItem(1, 100000)),
        'Samahani, zimebaki 180 tu za Vaseline Petroleum Jelly 400ml.',
      );
    },
  );

  test('addresses: sends the API field names', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'address_id': 2,
          'address_recipient_name': 'Test',
          'address_phone': '+255719000556',
          'region_id': 2,
          'region_name': 'Dar es Salaam',
          'district_id': 8,
          'district_name': 'Ilala',
          'address_street': 'Kariakoo',
          'address_landmark': null,
          'address_is_default': true,
        },
      }, statusCode: 201),
    );

    final address = await ApiAddressRepository(client).createAddress(
      const AddressInput(
        recipientName: 'Test',
        phone: '0719000556',
        regionId: 2,
        districtId: 8,
        street: 'Kariakoo',
      ),
    );

    expect(adapter.lastRequest!.data, {
      'address_recipient_name': 'Test',
      'address_phone': '0719000556',
      'region_id': 2,
      'district_id': 8,
      'address_street': 'Kariakoo',
      'address_landmark': null,
    });
    expect(address.fullLocation, 'Kariakoo, Ilala, Dar es Salaam');
    expect(address.isDefault, isTrue);
  });

  test(
    'checkout: options for the address; payment methods with their details',
    () async {
      final (client, adapter) = clientReplying(
        (_) => jsonReply({
          'success': true,
          'data': {
            'delivery_methods': [
              {
                'delivery_method_id': 1,
                'delivery_method_code': 'standard',
                'delivery_method_name': 'Standard (siku 2–3)',
                'delivery_method_fee': 5000,
                'delivery_days_min': 2,
                'delivery_days_max': 3,
                'region_id': null,
              },
            ],
            'payment_methods': ['mpesa', 'cod'],
            'payment_method_details': [
              {
                'payment_method_code': 'mpesa',
                'payment_method_name': 'M-Pesa',
                'payment_method_type': 'mobile_money',
                'payment_method_account_name': 'CHIMBO LTD',
                'payment_method_account_number': '5544332',
                'payment_method_bank_name': null,
                'payment_method_instructions': 'Piga *150*00#.',
              },
              {
                'payment_method_code': 'cod',
                'payment_method_name': 'Lipa ukipokea',
                'payment_method_type': 'cash',
                'payment_method_account_name': null,
                'payment_method_account_number': null,
                'payment_method_bank_name': null,
                'payment_method_instructions': null,
              },
            ],
          },
        }),
      );

      final options = await ApiCheckoutRepository(client)
          .getOptions(addressId: 3);

      expect(adapter.lastRequest!.uri.queryParameters, {'address_id': '3'});
      expect(options.deliveryMethods.single.name, 'Standard (siku 2–3)');
      final [mpesa, cash] = options.paymentMethods;
      expect(mpesa.name, 'M-Pesa');
      expect(mpesa.accountNumber, '5544332');
      expect(mpesa.isCashOnDelivery, isFalse);
      expect(cash.code, 'cod');
      expect(cash.isCashOnDelivery, isTrue);
    },
  );

  test('checkout: preview sends method and address, reads totals', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'line_count': 1,
          'piece_count': 8,
          'subtotal': 40000,
          'savings': 4000,
          'delivery_method_id': 1,
          'delivery_fee': 5000,
          'discount_total': 0,
          'grand_total': 45000,
          'delivery_days_min': 2,
          'delivery_days_max': 3,
        },
      }),
    );

    final preview = await ApiCheckoutRepository(client)
        .preview(deliveryMethodId: 1, addressId: 3);

    expect(adapter.lastRequest!.data, {
      'delivery_method_id': 1,
      'address_id': 3,
    });
    expect(preview.total, 45000);
  });

  test('payment methods: the public list with pay-to details', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': [
          {
            'payment_method_code': 'crdb',
            'payment_method_name': 'CRDB Benki',
            'payment_method_type': 'bank',
            'payment_method_account_name': 'CHIMBO LTD',
            'payment_method_account_number': '0150000000',
            'payment_method_bank_name': 'CRDB',
            'payment_method_instructions': null,
          },
        ],
      }),
    );

    final methods = await ApiCheckoutRepository(client).getPaymentMethods();

    expect(adapter.lastRequest!.uri.path, endsWith('/payment-methods'));
    expect(methods.single.bankName, 'CRDB');
  });
}
