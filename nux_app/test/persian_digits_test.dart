import 'package:flutter_test/flutter_test.dart';
import 'package:nux_app/core/utils/persian_digits.dart';

void main() {
  group('digit conversion', () {
    test('Latin → Persian', () {
      expect(toPersianDigits('0912'), '۰۹۱۲');
      expect(toPersianDigits(20), '۲۰');
      expect(toPersianDigits('abc 5'), 'abc ۵');
    });

    test('Persian / Arabic → Latin', () {
      expect(toLatinDigits('۰۹۱۲۳۴۵۶۷۸۹'), '09123456789');
      expect(toLatinDigits('٠٩١٢'), '0912');
    });
  });

  group('Iranian mobile numbers', () {
    test('accepts common formats', () {
      expect(normalizeIranMobile('09121234567'), '09121234567');
      expect(normalizeIranMobile('۰۹۱۲۱۲۳۴۵۶۷'), '09121234567');
      expect(normalizeIranMobile('9121234567'), '09121234567');
      expect(normalizeIranMobile('+989121234567'), '09121234567');
      expect(normalizeIranMobile('989121234567'), '09121234567');
      expect(normalizeIranMobile('0912 123 4567'), '09121234567');
    });

    test('rejects invalid numbers', () {
      expect(isValidIranMobile(''), isFalse);
      expect(isValidIranMobile('0912123'), isFalse);
      expect(isValidIranMobile('08121234567'), isFalse);
      expect(isValidIranMobile('091212345678'), isFalse);
      expect(isValidIranMobile('abcdefghijk'), isFalse);
    });
  });

  group('DigitsInputFormatter', () {
    const formatter = DigitsInputFormatter(maxLength: 4);
    TextEditingValue run(String text) => formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );

    test('keeps digits only, converts to Latin and caps the length', () {
      expect(run('۱۲a۳-4۵۶').text, '1234');
      expect(run('12').text, '12');
      expect(run('x').text, '');
    });
  });
}
