import 'package:flutter_test/flutter_test.dart';
import 'package:poplar/core/utils/phone_utils.dart';

void main() {
  group('PhoneUtils.normalizeKenyanNumber', () {
    test('normalizes common Kenyan formats consistently', () {
      expect(PhoneUtils.normalizeKenyanNumber('0712 345-678'), '+254712345678');
      expect(PhoneUtils.normalizeKenyanNumber('254712345678'), '+254712345678');
      expect(PhoneUtils.normalizeKenyanNumber('+254 (712) 345 678'), '+254712345678');
    });

    test('keeps international numbers intact', () {
      expect(PhoneUtils.normalizeKenyanNumber('+1 202 555 0100'), '+12025550100');
    });
  });
}
