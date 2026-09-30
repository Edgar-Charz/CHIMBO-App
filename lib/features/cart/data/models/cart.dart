import 'package:chimbo/features/catalog/data/models/product_summary.dart';

/// Why a line can't be ordered right now (after stock or the MOQ changed); checkout is blocked
/// until it's fixed.
enum CartLineProblem {
  /// Fewer left than the quantity: lower it to [CartLine.availableQuantity].
  notEnoughStock('not_enough_stock'),
  outOfStock('out_of_stock'),
  belowMoq('below_moq');

  const CartLineProblem(this.apiValue);

  final String apiValue;

  static CartLineProblem? fromApi(String? value) {
    for (final problem in values) {
      if (problem.apiValue == value) {
        return problem;
      }
    }
    return null;
  }
}

/// One product in the cart, priced by the server (blueprint §8.3: the app only displays it).
class CartLine {
  const CartLine({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.tierMinQuantity,
    required this.lineTotal,
    this.lineSavings = 0,
    this.nextTierExtraQuantity,
    this.nextTierUnitPrice,
    this.problem,
    this.availableQuantity,
  });

  factory CartLine.fromJson(Map<String, dynamic> json) {
    final hint = json['next_tier_hint'] as Map<String, dynamic>?;
    return CartLine(
      product: ProductSummary.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['cart_quantity'] as int,
      unitPrice: json['unit_price'] as int,
      tierMinQuantity: json['tier_min_quantity'] as int,
      lineTotal: json['line_total'] as int,
      lineSavings: json['line_savings'] as int? ?? 0,
      nextTierExtraQuantity: hint?['extra_quantity'] as int?,
      nextTierUnitPrice: hint?['unit_price'] as int?,
      problem: CartLineProblem.fromApi(json['line_problem'] as String?),
      availableQuantity: json['available_quantity'] as int?,
    );
  }

  final ProductSummary product;
  final int quantity;

  /// Price of the tier this quantity reached ("6+ pcs @ TZS 5,000").
  final int unitPrice;
  final int tierMinQuantity;
  final int lineTotal;

  /// "Unaokoa" for this line: what the tier saves compared with the MOQ price.
  final int lineSavings;

  /// "Ongeza pcs 16 upate TZS 4,700": null when the best tier is reached.
  final int? nextTierExtraQuantity;
  final int? nextTierUnitPrice;

  /// Null when the line is fine.
  final CartLineProblem? problem;

  /// How many are left in stock (the stepper's upper limit).
  final int? availableQuantity;

  /// MOQ is a hard minimum (D-8).
  bool get isMoqMet =>
      quantity >= product.moq && problem != CartLineProblem.belowMoq;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'cart_quantity': quantity,
    'unit_price': unitPrice,
    'tier_min_quantity': tierMinQuantity,
    'line_total': lineTotal,
    'line_savings': lineSavings,
    'line_problem': problem?.apiValue,
    'available_quantity': availableQuantity,
    'next_tier_hint': nextTierExtraQuantity == null
        ? null
        : {
            'extra_quantity': nextTierExtraQuantity,
            'unit_price': nextTierUnitPrice,
          },
  };
}

/// Lines of one top category ("Cosmetics", "Jewelry").
class CartGroup {
  const CartGroup({required this.categoryName, required this.lines});

  factory CartGroup.fromJson(Map<String, dynamic> json) {
    return CartGroup(
      categoryName: json['category_name'] as String,
      lines: (json['items'] as List<dynamic>)
          .map((line) => CartLine.fromJson(line as Map<String, dynamic>))
          .toList(),
    );
  }

  final String categoryName;
  final List<CartLine> lines;

  Map<String, dynamic> toJson() => {
    'category_name': categoryName,
    'items': lines.map((line) => line.toJson()).toList(),
  };
}

/// `GET /cart`: the whole priced cart. Every cart change returns a new one.
class Cart {
  const Cart({
    required this.groups,
    required this.lineCount,
    required this.pieceCount,
    required this.subtotal,
    this.savings = 0,
    this._canCheckout = true,
    this.warnings = const [],
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return Cart(
      groups: (json['groups'] as List<dynamic>)
          .map((group) => CartGroup.fromJson(group as Map<String, dynamic>))
          .toList(),
      lineCount: summary['line_count'] as int,
      pieceCount: summary['piece_count'] as int,
      subtotal: summary['subtotal'] as int,
      savings: summary['savings'] as int? ?? 0,
      canCheckout: summary['can_checkout'] as bool? ?? true,
      warnings: [
        for (final warning in json['warnings'] as List<dynamic>? ?? const [])
          _warningText(warning),
      ].whereType<String>().toList(),
    );
  }

  /// A warning is a ready-to-show message, or an object carrying one.
  static String? _warningText(Object? warning) => switch (warning) {
    final String message => message,
    {'message': final String message} => message,
    _ => null,
  };

  static const Cart empty = Cart(
    groups: [],
    lineCount: 0,
    pieceCount: 0,
    subtotal: 0,
  );

  final List<CartGroup> groups;

  /// Number of different products — the badge and "Bidhaa (n)" (I-3).
  final int lineCount;
  final int pieceCount;
  final int subtotal;

  /// "Unaokoa" for the whole cart.
  final int savings;

  /// False while a line has a [CartLineProblem]: checkout is blocked.
  final bool? _canCheckout;

  /// Default to true when an in-memory cart predates this field after hot reload.
  bool get canCheckout => _canCheckout ?? true;

  /// Messages about products that left the shop (removed from the cart); shown once.
  final List<String> warnings;

  bool get isEmpty => lineCount == 0;

  Iterable<CartLine> get lines => groups.expand((group) => group.lines);

  /// The line closest to a better price, for the "Ongeza …" banner (D-7: per-item nudges).
  CartLine? get bestNudge {
    CartLine? best;
    for (final line in lines) {
      final extra = line.nextTierExtraQuantity;
      if (extra != null &&
          (best == null || extra < best.nextTierExtraQuantity!)) {
        best = line;
      }
    }
    return best;
  }

  int quantityOf(int productId) {
    for (final line in lines) {
      if (line.product.id == productId) {
        return line.quantity;
      }
    }
    return 0;
  }
}
