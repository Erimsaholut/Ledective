/// The Turkish alphabet, in order, that the letter ciphers work on.
const alphabet = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ";

/// Upper case the Turkish way: i becomes İ and ı becomes I.
String turkishUpper(String text) =>
    text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// A way to hide a message.
enum Cipher {
  caesar("Sezar", '🔐', "Her harf alfabede birkaç harf kaydırılır."),
  atbash("Atbaş", '🔁', "Alfabe ters çevrilir: A↔Z, B↔Y…"),
  morse("Mors", '📡', "Harfler nokta ve çizgiye dönüşür; tersi de olur."),
  reverse("Tersten", '↩️', "Mesaj sondan başa yazılır.");

  const Cipher(this.title, this.emoji, this.hint);

  final String title;
  final String emoji;
  final String hint;
}

/// Moves every letter of [text] [shift] places along the alphabet, from
/// Z round to A. A negative shift moves back, which undoes it. Anything
/// that isn't a letter stays as it is.
String caesar(String text, int shift) => _mapLetters(text, (index) {
  final n = alphabet.length;
  return ((index + shift) % n + n) % n;
});

/// Swaps every letter for its mirror in the alphabet. Doing it twice gives
/// the message back.
String atbash(String text) =>
    _mapLetters(text, (index) => alphabet.length - 1 - index);

String _mapLetters(String text, int Function(int index) map) {
  final out = StringBuffer();
  for (final char in turkishUpper(text).split('')) {
    final index = alphabet.indexOf(char);
    out.write(index < 0 ? char : alphabet[map(index)]);
  }
  return out.toString();
}

String reverse(String text) => text.split('').reversed.join();

const Map<String, String> _morse = {
  'A': '.-', 'B': '-...', 'C': '-.-.', 'Ç': '-.-..', 'D': '-..', //
  'E': '.', 'F': '..-.', 'G': '--.', 'Ğ': '--.-.', 'H': '....',
  'I': '..', 'İ': '.-..-', 'J': '.---', 'K': '-.-', 'L': '.-..',
  'M': '--', 'N': '-.', 'O': '---', 'Ö': '---.', 'P': '.--.',
  'Q': '--.-', 'R': '.-.', 'S': '...', 'Ş': '.--..', 'T': '-',
  'U': '..-', 'Ü': '..--', 'V': '...-', 'W': '.--', 'X': '-..-',
  'Y': '-.--', 'Z': '--..',
  '0': '-----', '1': '.----', '2': '..---', '3': '...--', '4': '....-',
  '5': '.....', '6': '-....', '7': '--...', '8': '---..', '9': '----.',
};

/// Whether [text] is made of dots, dashes and gaps, so it is Morse to read
/// rather than words to write in Morse.
bool isMorse(String text) =>
    text.trim().isNotEmpty && RegExp(r'^[.\-\s/]+$').hasMatch(text.trim());

/// Writes [text] in Morse: letters apart by a space, words by " / ".
String toMorse(String text) => turkishUpper(text)
    .trim()
    .split(RegExp(r'\s+'))
    .map((word) => word.split('').map((c) => _morse[c] ?? '?').join(' '))
    .join(' / ');

/// Reads Morse written as [toMorse] writes it.
String fromMorse(String code) {
  final letters = {for (final e in _morse.entries) e.value: e.key};
  return code
      .trim()
      .split(RegExp(r'\s*/\s*'))
      .map(
        (word) => word
            .split(RegExp(r'\s+'))
            .where((c) => c.isNotEmpty)
            .map((c) => letters[c] ?? '?')
            .join(),
      )
      .join(' ');
}

/// [text] put through [cipher]; for Morse, read or written depending on
/// what [text] is.
String apply(Cipher cipher, String text, {int shift = 3}) => switch (cipher) {
  Cipher.caesar => caesar(text, shift),
  Cipher.atbash => atbash(text),
  Cipher.morse => isMorse(text) ? fromMorse(text) : toMorse(text),
  Cipher.reverse => reverse(text),
};
