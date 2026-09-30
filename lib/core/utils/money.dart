import 'package:intl/intl.dart';

/// Formats whole-shilling amounts the way CHIMBO shows money everywhere: `TZS 5,500`.
abstract final class Money {
  static const String currencyCode = 'TZS';

  static final NumberFormat _thousands = NumberFormat('#,##0', 'en_US');

  static String format(int amountInShillings) {
    return '$currencyCode ${_thousands.format(amountInShillings)}';
  }
}
