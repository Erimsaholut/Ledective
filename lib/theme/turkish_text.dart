/// Lower-cases and strips Turkish letters, so "ozge" finds "Özge".
String searchKey(String text) {
  const map = {'ı': 'i', 'ş': 's', 'ç': 'c', 'ğ': 'g', 'ö': 'o', 'ü': 'u'};
  final lower = text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
  return lower.split('').map((c) => map[c] ?? c).join();
}

/// [text] in capitals the Turkish way: `i` becomes `İ`, `ı` becomes `I`.
String turkishUpper(String text) =>
    text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
