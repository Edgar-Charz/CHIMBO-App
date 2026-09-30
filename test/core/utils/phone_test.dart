import 'package:chimbo/core/utils/phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TzPhone.normalize', () {
    test('accepts every common way of writing a Tanzanian mobile', () {
      for (final input in [
        '0712345678',
        '712345678',
        '255712345678',
        '+255 712 345 678',
        '+255-712-345-678',
      ]) {
        expect(TzPhone.normalize(input), '+255712345678', reason: input);
      }
      expect(TzPhone.normalize('0612345678'), '+255612345678');
    });

    test('rejects numbers that are not Tanzanian mobiles', () {
      for (final input in [
        '',
        '71234567', // too short
        '7123456789', // too long
        '0512345678', // not 6 or 7
        '254712345678', // Kenya
      ]) {
        expect(TzPhone.normalize(input), isNull, reason: input);
      }
    });
  });

  test('format groups the local digits', () {
    expect(TzPhone.format('+255712345678'), '+255 712 345 678');
    expect(TzPhone.groupLocalDigits('7123'), '712 3');
  });
}
