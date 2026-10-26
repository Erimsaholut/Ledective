/// Groups a string of digits the way Turkish phone numbers are written:
/// `0535 031 53 53` when it starts with 0, otherwise `535 031 53 53`.
String formatPhoneNumber(String digits) {
  final groups = digits.startsWith('0') ? [4, 3, 2, 2] : [3, 3, 2, 2];
  final parts = <String>[];
  var start = 0;
  for (final length in groups) {
    if (start >= digits.length) break;
    final end = (start + length).clamp(0, digits.length);
    parts.add(digits.substring(start, end));
    start = end;
  }
  if (start < digits.length) parts.add(digits.substring(start));
  return parts.join(' ');
}

/// Longest number the keypad accepts.
const int maxPhoneDigits = 11;

String digitsOnly(String number) => number.replaceAll(RegExp(r'\D'), '');
