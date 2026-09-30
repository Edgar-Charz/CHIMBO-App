import 'package:chimbo/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats whole shillings with thousands separators and no decimals', () {
    expect(Money.format(0), 'TZS 0');
    expect(Money.format(950), 'TZS 950');
    expect(Money.format(5500), 'TZS 5,500');
    expect(Money.format(1250000), 'TZS 1,250,000');
  });
}
