import 'dart:math';

import '../theme/turkish_dates.dart';
import 'dialogue.dart';

/// Small signs, before the hidden ending, that something is wrong. They
/// start once the player has gone a few steps down that road (`doubt`)
/// and come more often the further they go.
abstract final class Omens {
  /// Whether the home clock shows upside down at [now]: for a few seconds
  /// every four minutes from doubt 2, every two from doubt 4.
  static bool clockFlipped(int doubt, DateTime now) {
    if (doubt < 2) return false;
    final every = doubt >= 4 ? 2 : 4;
    return now.minute % every == 1 && now.second < 15;
  }
}

/// How far the phone has fallen apart in the hidden ending, [elapsed]
/// play time after it began. Each app asks what to show: numbers go wrong
/// first, then the photos change, then Mail fills with one message, then
/// the chats erase themselves, and last the caregiver's recording comes.
class Breakdown {
  const Breakdown(this.elapsed);

  final Duration elapsed;

  static const photosFrom = Duration(seconds: 15);
  static const mailFrom = Duration(seconds: 35);
  static const chatsFrom = Duration(seconds: 55);
  static const finaleAt = Duration(seconds: 90);

  /// What every flooding mail says.
  static const madLine = 'SEN DELİ DEĞİLSİN';

  /// What an erased chat message says.
  static const erased = '🚫 Bu mesaj silindi';

  /// The pictures that take the gallery's place, one by one.
  static const photos = [
    'assets/story/images/bozulma_ilaclar.jpg',
    'assets/story/images/bozulma_koridor.jpg',
    'assets/story/images/bozulma_pencere.jpg',
    'assets/story/images/bozulma_ilac_kutusu.jpg',
    'assets/story/images/bozulma_bileklik.jpg',
    'assets/story/images/bozulma_oda.jpg',
  ];

  int get _seconds => elapsed.inSeconds;

  /// Gallery photos replaced so far: one every six seconds.
  int get brokenPhotos =>
      elapsed < photosFrom ? 0 : (elapsed - photosFrom).inSeconds ~/ 6 + 1;

  /// Copies of the [madLine] mail so far: a few more every second.
  int get madMails =>
      elapsed < mailFrom ? 0 : min(300, (elapsed - mailFrom).inSeconds * 4 + 6);

  /// Chat messages erased so far, oldest first: about three a second.
  int get erasedMessages =>
      elapsed < chatsFrom ? 0 : (elapsed - chatsFrom).inMilliseconds ~/ 350 + 1;

  bool get finale => elapsed >= finaleAt;

  /// The home screen clock: now and then the real time, mostly not.
  String clock(DateTime now) => switch (_seconds % 7) {
    0 || 1 => '88:88',
    2 => '03:00',
    3 => '--:--',
    _ => clockTime(now),
  };

  /// A badge that no longer counts anything.
  String badge(int salt) {
    const odd = ['999+', '88', '3', '303', '12', '7777', '1', '44', '0'];
    return odd[(_seconds ~/ 2 * 7 + salt).abs() % odd.length];
  }

  /// A bank balance that makes no sense.
  String money(int salt) {
    const odd = [
      '88.888.888,88 TL',
      '-0,01 TL',
      '0,00 TL',
      '??.???,?? TL',
      '-1.245.075,00 TL',
    ];
    return odd[(_seconds ~/ 3 + salt).abs() % odd.length];
  }

  /// [gallery] with the first [brokenPhotos] swapped for [photos].
  List<String> gallery(List<String> gallery) => [
    for (final (i, photo) in gallery.indexed)
      i < brokenPhotos ? photos[i % photos.length] : photo,
    for (var i = gallery.length; i < brokenPhotos && i < photos.length; i++)
      photos[i],
  ];

  /// [transcript] with its first [erasedMessages] messages erased.
  List<ChatEntry> erase(List<ChatEntry> transcript) {
    var left = erasedMessages;
    return [
      for (final entry in transcript)
        switch (entry) {
          IncomingMessage() when left-- > 0 => const IncomingMessage(erased),
          OutgoingMessage() when left-- > 0 => const OutgoingMessage(erased),
          _ => entry,
        },
    ];
  }

  /// Whether every message of [transcript] has been erased.
  bool gone(List<ChatEntry> transcript) =>
      transcript.whereType<IncomingMessage>().length +
          transcript.whereType<OutgoingMessage>().length <=
      erasedMessages;
}
