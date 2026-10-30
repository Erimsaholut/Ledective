import 'package:flutter/material.dart';

import '../../home/app_icon.dart';
import '../games/castle_guard/castle_guard_app.dart';
import '../games/farm/farm_app.dart';
import '../games/farm/farm_reminder.dart';
import '../games/space_runner/space_runner_app.dart';
import '../games/sudoku/sudoku_app.dart';
import '../store_apps/cipher/cipher_app.dart';
import '../store_apps/pro_calculator/pro_calculator_app.dart';
import '../store_apps/unit_converter/unit_converter_app.dart';

/// Which shelf of AppShop something sits on.
enum StoreKind { game, app }

/// A screenshot on a store page, drawn as a card with an emoji scene.
class StorePreview {
  const StorePreview(this.emoji, this.caption);

  final String emoji;
  final String caption;
}

/// A player's review on a store page.
class StoreReview {
  const StoreReview({
    required this.author,
    required this.stars,
    required this.title,
    required this.text,
  });

  final String author;
  final int stars;
  final String title;
  final String text;
}

/// A game or app that can be downloaded from AppShop. Once installed it
/// gets its own icon on the home screen.
class StoreItem {
  const StoreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    this.kind = StoreKind.game,
    this.tagline = "",
    this.category = "",
    this.developer = "Bağımsız Geliştirici",
    this.rating = 4.5,
    this.ratings = 1200,
    this.sizeMb = 40,
    this.age = "4+",
    this.version = "1.0",
    this.whatsNew = "",
    this.previews = const [],
    this.reviews = const [],
    this.featured,
    this.app,
    this.inDevelopment = false,
    this.glyphColor = Colors.white,
    this.dataKeys = const [],
  });

  /// Saved with the installed games; never change it once released.
  final String id;
  final String title;
  final String description;
  final IconData icon;

  /// Icon gradient, top to bottom.
  final List<Color> colors;
  final Color glyphColor;
  final StoreKind kind;

  /// A line under the title, e.g. "Kuleni kur, kaleni koru".
  final String tagline;
  final String category;
  final String developer;

  /// Average stars out of five, and how many gave them.
  final double rating;
  final int ratings;
  final int sizeMb;

  /// Age rating, e.g. "9+".
  final String age;
  final String version;
  final String whatsNew;
  final List<StorePreview> previews;
  final List<StoreReview> reviews;

  /// What the editors say when the store puts it forward, or null if it
  /// isn't one of their picks.
  final String? featured;

  /// The game itself, or null for one the store lists but won't download:
  /// not offered in the player's country, or [inDevelopment].
  final Widget? app;

  /// Announced but not finished yet.
  final bool inDevelopment;

  /// SharedPreferences keys the game saves to, removed when it's deleted.
  final List<String> dataKeys;

  bool get isAvailable => app != null;
  bool get isFeatured => featured != null;

  /// The icon of an available game.
  AppIcon get homeIcon => AppIcon(
    title: title,
    app: app!,
    iconData: icon,
    colors: colors,
    glyphColor: glyphColor,
  );
}

/// Everything AppShop offers, best first on each shelf. Adding a game or
/// an app takes one entry here.
const List<StoreItem> storeItems = [
  StoreItem(
    id: 'castle-guard',
    title: "Kale Muhafızı",
    tagline: "Kuleni kur, kaleni koru",
    description:
        "Yolun kenarına kuleler kur, üç haritada 20'şer dalga boyunca "
        "goblinlere, devlere ve ejderhalara karşı kaleni koru. Okçu, top ve "
        "buz kulelerini geliştir, altın madenleriyle hazineni büyüt. Üç "
        "haritayı da kurtaranları sonu gelmeyen dalgalarıyla Sonsuz Mod "
        "bekliyor.",
    icon: Icons.castle_rounded,
    colors: [Color(0xFF8D99AE), Color(0xFF2B2D42)],
    category: "Strateji",
    developer: "Kuzgun Oyun Stüdyosu",
    rating: 4.8,
    ratings: 18400,
    sizeMb: 96,
    age: "9+",
    version: "2.1",
    whatsNew:
        "Altın Madeni geldi: başta pahalı, sonra servet! Üç haritayı "
        "kurtaranlara Sonsuz Mod açıldı.",
    previews: [
      StorePreview('🏹', "Okçu, top ve buz kuleleri"),
      StorePreview('🐉', "Ejderhalara karşı dayan"),
      StorePreview('🗺️', "Üç harita, artan zorluk"),
      StorePreview('♾️', "Bitmeyen Sonsuz Mod"),
    ],
    reviews: [
      StoreReview(
        author: "kulekral34",
        stars: 5,
        title: "Bırakamıyorum",
        text:
            "Ejderha Dağı'nı üçüncü denemede geçtim. Madenler oyunun "
            "dengesini tamamen değiştiriyor.",
      ),
      StoreReview(
        author: "Selin K.",
        stars: 4,
        title: "Çok güzel ama zor",
        text:
            "Bataklık haritası beni epey uğraştırdı. Önizleme özelliği "
            "harika olmuş.",
      ),
    ],
    featured:
        "Bu hafta editörlerimizin gözdesi: sade görünüşünün altında "
        "derin bir strateji yatıyor.",
    app: CastleGuardApp(),
    dataKeys: [
      CastleGuardApp.bestKey,
      CastleGuardApp.profileKey,
      CastleGuardApp.gameKey,
    ],
  ),
  StoreItem(
    id: 'farm',
    title: "Bereket Çiftliği",
    tagline: "Ek, biç, büyüt, köyün en iyisi ol",
    description:
        "Tarlanı ek, ürünlerini sat, yeni tarlalar ve aletler al. Ürünler "
        "sen yokken de büyür. Tavuk, inek, koyun ve arı besle, komşuların "
        "siparişlerini yetiştir, köy liginde Tahta'dan Elmas'a yüksel. "
        "Çiftliğini temalar, süsler ve şapkalarla kendine göre donat.",
    icon: Icons.agriculture_rounded,
    colors: [Color(0xFF9BE15D), Color(0xFF2E7D32)],
    category: "Simülasyon",
    developer: "Toprak Games",
    rating: 4.7,
    ratings: 52300,
    sizeMb: 124,
    version: "3.4",
    whatsNew:
        "Komşularının profillerine göz at, kış temasında karlar yağsın. "
        "Süsleri artık tarlada gizleyebilirsin.",
    previews: [
      StorePreview('🌾', "Ürünler sen yokken de büyür"),
      StorePreview('🐄', "Hayvanlarını besle"),
      StorePreview('🏆', "Köy liginde zirveye çık"),
      StorePreview('❄️', "Temalar ve süsler"),
    ],
    reviews: [
      StoreReview(
        author: "Hatice Teyze",
        stars: 5,
        title: "Torunlarım da oynuyor",
        text: "Sabah kalkınca ilk iş tarlaya bakıyorum. Arılar çok tatlı.",
      ),
      StoreReview(
        author: "mert_06",
        stars: 4,
        title: "Lig çok rekabetçi",
        text: "Hasan Dayı her hafta beni geçiyor, bu adam uyumuyor mu?",
      ),
    ],
    featured:
        "Tarlası, hayvanları ve köy ligiyle her gün geri dönmek "
        "isteyeceğin bir çiftlik.",
    app: FarmApp(),
    dataKeys: [FarmApp.saveKey, FarmReminder.saveKey],
  ),
  StoreItem(
    id: 'sudoku',
    title: "Sudoku",
    tagline: "Klasik sayı bulmacası",
    description:
        "Klasik sayı bulmacası. Üç zorluk seviyesi, kalem notları ve ipuçları.",
    icon: Icons.grid_3x3_rounded,
    colors: [Color(0xFF5B8DEF), Color(0xFF1F3F9A)],
    category: "Bulmaca",
    developer: "Mantık Atölyesi",
    rating: 4.6,
    ratings: 9800,
    sizeMb: 22,
    previews: [
      StorePreview('🔢', "Üç zorluk seviyesi"),
      StorePreview('✏️', "Kalem notları"),
    ],
    app: SudokuApp(),
    dataKeys: [SudokuApp.saveKey],
  ),
  StoreItem(
    id: 'space-runner',
    title: "Uzay Kaçağı",
    tagline: "Yakıtın bitmeden kaç",
    description:
        "Asteroitlerin arasından geç, yakıtın bitmeden galaksiden kaç.",
    icon: Icons.rocket_launch_rounded,
    colors: [Color(0xFF7F5AF0), Color(0xFF16123F)],
    category: "Arcade",
    developer: "Nebula Works",
    rating: 4.3,
    ratings: 6100,
    sizeMb: 58,
    previews: [
      StorePreview('🚀', "Asteroitlerden kaç"),
      StorePreview('⛽', "Yakıtı topla"),
    ],
    app: SpaceRunnerApp(),
    dataKeys: [SpaceRunnerApp.bestKey],
  ),
  StoreItem(
    id: 'word-hunt',
    title: "Kelime Avı",
    tagline: "Harflerden kelime türet",
    description:
        "Karışık harflerden kelime türet, süre dolmadan en yüksek puanı topla.",
    icon: Icons.abc_rounded,
    colors: [Color(0xFFFFD166), Color(0xFFF77F00)],
    category: "Kelime",
    developer: "Mantık Atölyesi",
    rating: 0,
    ratings: 0,
    inDevelopment: true,
  ),
  StoreItem(
    id: 'track-monster',
    title: "Pist Canavarı",
    tagline: "Drift at, rakiplerini geç",
    description: "Arabanı modifiye et, virajlarda drift at, rakiplerini geç.",
    icon: Icons.sports_motorsports_rounded,
    colors: [Color(0xFFFF6B6B), Color(0xFFC0392B)],
    category: "Yarış",
    developer: "Turbo Interactive",
    rating: 4.1,
    ratings: 33800,
    sizeMb: 1450,
    age: "12+",
  ),
  StoreItem(
    id: 'cipher',
    kind: StoreKind.app,
    title: "Şifre Çözücü",
    tagline: "Gizli mesajları çöz",
    description:
        "Sezar kaydırması, Atbaş, Mors alfabesi ve ters yazı. Bir mesajı "
        "şifrele ya da şifreli bir notu çöz; Sezar için bütün kaydırmaları "
        "tek ekranda dene. Türkçe harflerle çalışır.",
    icon: Icons.key_rounded,
    colors: [Color(0xFF3A3A3C), Color(0xFF111111)],
    glyphColor: Color(0xFFFFD60A),
    category: "Araçlar",
    developer: "Kuzgun Oyun Stüdyosu",
    rating: 4.7,
    ratings: 2300,
    sizeMb: 8,
    previews: [
      StorePreview('🔐', "Sezar ve Atbaş"),
      StorePreview('📡', "Mors alfabesi"),
      StorePreview('🕵️', "Bütün kaydırmaları dene"),
    ],
    reviews: [
      StoreReview(
        author: "dedektif_ayse",
        stars: 5,
        title: "Tam aradığım şey",
        text: "Eski bir mektuptaki şifreyi iki dakikada çözdüm.",
      ),
    ],
    featured: "Meraklı zihinler için: şifreli notları saniyeler içinde çöz.",
    app: CipherApp(),
  ),
  StoreItem(
    id: 'pro-calculator',
    kind: StoreKind.app,
    title: "Hesap Makinesi Pro",
    tagline: "Bilimsel hesap makinesi",
    description:
        "Parantezler, üsler, kökler, trigonometri ve logaritma. Yazdığın "
        "işlemin sonucunu anında gösterir, geçmiş hesaplarını saklar.",
    icon: Icons.functions_rounded,
    colors: [Color(0xFFFF9F0A), Color(0xFFD35400)],
    category: "Verimlilik",
    developer: "Mantık Atölyesi",
    rating: 4.8,
    ratings: 7400,
    sizeMb: 12,
    previews: [
      StorePreview('🧮', "Bilimsel işlemler"),
      StorePreview('🕘', "Hesap geçmişi"),
    ],
    reviews: [
      StoreReview(
        author: "mühendis_can",
        stars: 5,
        title: "Sade ve güçlü",
        text: "Derece/radyan geçişi tek dokunuşta, geçmiş çok işe yarıyor.",
      ),
    ],
    app: ProCalculatorApp(),
    dataKeys: [ProCalculatorApp.historyKey],
  ),
  StoreItem(
    id: 'unit-converter',
    kind: StoreKind.app,
    title: "Birim Çevirici",
    tagline: "Uzunluk, ağırlık, sıcaklık ve fazlası",
    description:
        "Uzunluk, ağırlık, sıcaklık, alan, hacim ve hız birimlerini "
        "anında çevir. Bir değeri yaz, bütün birimlerdeki karşılığını gör.",
    icon: Icons.straighten_rounded,
    colors: [Color(0xFF34C759), Color(0xFF0B7A3E)],
    category: "Araçlar",
    developer: "Ölçü Yazılım",
    rating: 4.5,
    ratings: 3100,
    sizeMb: 9,
    previews: [
      StorePreview('📏', "Altı ölçü türü"),
      StorePreview('🌡️', "Sıcaklık dahil"),
    ],
    app: UnitConverterApp(),
  ),
];

/// The store items in [ids], in that order; unknown and unavailable ids
/// are skipped.
List<StoreItem> storeItemsWithIds(Iterable<String> ids) => [
  for (final id in ids)
    ...storeItems.where((game) => game.id == id && game.isAvailable),
];
