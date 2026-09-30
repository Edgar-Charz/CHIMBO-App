/// Tanzanian mobile numbers — the same rules as the backend's `Phone.php`, so the app rejects a
/// bad number before sending it.
abstract final class TzPhone {
  static const String countryCode = '+255';

  /// Digits after the country code: 9, starting with 6 or 7.
  static const int localLength = 9;

  static final RegExp _localMobile = RegExp(r'^[67]\d{8}$');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// Returns the number as `+255XXXXXXXXX`, or null if it is not a valid Tanzanian mobile.
  /// Accepts `0712345678`, `712345678`, `255712345678`, `+255 712 345 678`.
  static String? normalize(String input) {
    final digits = input.replaceAll(_nonDigits, '');
    final local = switch (digits.length) {
      12 when digits.startsWith('255') => digits.substring(3),
      10 when digits.startsWith('0') => digits.substring(1),
      localLength => digits,
      _ => null,
    };
    if (local == null || !_localMobile.hasMatch(local)) {
      return null;
    }
    return '$countryCode$local';
  }

  /// `+255712345678` → `+255 712 345 678` (for display).
  static String format(String e164) {
    if (!e164.startsWith(countryCode) ||
        e164.length != countryCode.length + localLength) {
      return e164;
    }
    return '$countryCode ${groupLocalDigits(e164.substring(countryCode.length))}';
  }

  /// `712345678` → `712 345 678`; shorter input is grouped as far as it goes (for typing).
  static String groupLocalDigits(String digits) {
    final groups = <String>[];
    for (var start = 0; start < digits.length; start += 3) {
      final end = start + 3 < digits.length ? start + 3 : digits.length;
      groups.add(digits.substring(start, end));
    }
    return groups.join(' ');
  }
}
