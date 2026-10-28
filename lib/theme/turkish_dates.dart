const List<String> turkishMonths = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

const List<String> turkishWeekdays = [
  'Pazartesi',
  'Salı',
  'Çarşamba',
  'Perşembe',
  'Cuma',
  'Cumartesi',
  'Pazar',
];

const List<String> turkishWeekdayAbbreviations = [
  'Pzt',
  'Sal',
  'Çar',
  'Per',
  'Cum',
  'Cmt',
  'Paz',
];

/// `26 Ekim Pazartesi`
String longTurkishDate(DateTime date) =>
    '${date.day} ${turkishMonths[date.month - 1]} '
    '${turkishWeekdays[date.weekday - 1]}';

/// `09:41`
String clockTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

/// When something arrived, the way phones list it: `14:05` today, `Dün`,
/// the weekday within a week, else `05.03`.
String shortStamp(DateTime time, [DateTime? now]) {
  final today = now ?? DateTime.now();
  final days = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(time.year, time.month, time.day)).inDays;
  if (days <= 0) return clockTime(time);
  if (days == 1) return 'Dün';
  if (days < 7) return turkishWeekdays[time.weekday - 1];
  return '${time.day.toString().padLeft(2, '0')}.'
      '${time.month.toString().padLeft(2, '0')}';
}
