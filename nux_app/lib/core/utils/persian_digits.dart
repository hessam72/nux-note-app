import 'package:flutter/services.dart';

const _persian = '۰۱۲۳۴۵۶۷۸۹';
const _arabic = '٠١٢٣٤٥٦٧٨٩';

/// Replaces Latin digits with Persian ones (for display).
String toPersianDigits(Object value) {
  final buffer = StringBuffer();
  for (final unit in value.toString().codeUnits) {
    final char = String.fromCharCode(unit);
    final index = '0123456789'.indexOf(char);
    buffer.write(index == -1 ? char : _persian[index]);
  }
  return buffer.toString();
}

/// Replaces Persian / Arabic-Indic digits with Latin ones (for logic).
String toLatinDigits(String value) {
  final buffer = StringBuffer();
  for (final unit in value.codeUnits) {
    final char = String.fromCharCode(unit);
    var index = _persian.indexOf(char);
    if (index == -1) index = _arabic.indexOf(char);
    buffer.write(index == -1 ? char : '$index');
  }
  return buffer.toString();
}

/// Iranian mobile number, e.g. `09121234567` (also accepts `+98…` / `98…` /
/// `9…` and Persian digits).
bool isValidIranMobile(String input) => normalizeIranMobile(input) != null;

/// Returns the number as `09xxxxxxxxx`, or `null` if it is not valid.
String? normalizeIranMobile(String input) {
  var digits = toLatinDigits(input).replaceAll(RegExp(r'[\s\-()]'), '');
  if (digits.startsWith('+98')) digits = '0${digits.substring(3)}';
  if (digits.startsWith('0098')) digits = '0${digits.substring(4)}';
  if (digits.startsWith('98') && digits.length == 12) {
    digits = '0${digits.substring(2)}';
  }
  if (digits.length == 10 && digits.startsWith('9')) digits = '0$digits';
  return RegExp(r'^09\d{9}$').hasMatch(digits) ? digits : null;
}

/// Accepts Persian / Arabic / Latin digits, stores them as Latin and caps the
/// length.
class DigitsInputFormatter extends TextInputFormatter {
  const DigitsInputFormatter({required this.maxLength});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final latin = toLatinDigits(newValue.text);
    final digits = latin.replaceAll(RegExp(r'[^0-9]'), '');
    final clipped = digits.length > maxLength
        ? digits.substring(0, maxLength)
        : digits;
    if (clipped == newValue.text) return newValue;
    return TextEditingValue(
      text: clipped,
      selection: TextSelection.collapsed(offset: clipped.length),
    );
  }
}
