/// What a cosmetic changes.
enum CosmeticSlot {
  /// The farm's colours; one is in use at a time.
  theme,

  /// Something for the garden; every one bought is shown.
  decoration,

  /// What the farmer wears in the league table; one at a time.
  hat,
}

/// Something bought with coins purely for looks.
class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.name,
    required this.emoji,
    required this.slot,
    required this.price,
    this.background,
    this.soil,
  });

  /// Saved with the farm; never change it once released.
  final String id;
  final String name;
  final String emoji;
  final CosmeticSlot slot;
  final int price;

  /// For a theme, the ARGB colours of the farm's background and soil.
  final int? background;
  final int? soil;
}

/// The look a farm starts with; it is free and always owned.
const springTheme = Cosmetic(
  id: 'spring',
  name: "Bahar",
  emoji: '🌱',
  slot: CosmeticSlot.theme,
  price: 0,
  background: 0xFFE8F5D6,
  soil: 0xFF8D5A3B,
);

const List<Cosmetic> cosmetics = [
  springTheme,
  Cosmetic(
    id: 'autumn',
    name: "Sonbahar",
    emoji: '🍂',
    slot: CosmeticSlot.theme,
    price: 1500,
    background: 0xFFFBE3C4,
    soil: 0xFF7A4A2A,
  ),
  Cosmetic(
    id: 'winter',
    name: "Kış",
    emoji: '❄️',
    slot: CosmeticSlot.theme,
    price: 4000,
    background: 0xFFE3F0FA,
    soil: 0xFF6D5A50,
  ),
  Cosmetic(
    id: 'lavender',
    name: "Lavanta Bahçesi",
    emoji: '💜',
    slot: CosmeticSlot.theme,
    price: 9000,
    background: 0xFFEDE3F7,
    soil: 0xFF6B4E71,
  ),
  Cosmetic(
    id: 'golden',
    name: "Altın Hasat",
    emoji: '✨',
    slot: CosmeticSlot.theme,
    price: 25000,
    background: 0xFFFFF3C4,
    soil: 0xFFA0701F,
  ),
  Cosmetic(
    id: 'tree',
    name: "Ulu Çınar",
    emoji: '🌳',
    slot: CosmeticSlot.decoration,
    price: 300,
  ),
  Cosmetic(
    id: 'tulips',
    name: "Lale Tarhı",
    emoji: '🌷',
    slot: CosmeticSlot.decoration,
    price: 600,
  ),
  Cosmetic(
    id: 'dog',
    name: "Çoban Köpeği",
    emoji: '🐕',
    slot: CosmeticSlot.decoration,
    price: 1200,
  ),
  Cosmetic(
    id: 'cat',
    name: "Tekir Kedi",
    emoji: '🐈',
    slot: CosmeticSlot.decoration,
    price: 1200,
  ),
  Cosmetic(
    id: 'evil-eye',
    name: "Nazar Boncuğu",
    emoji: '🧿',
    slot: CosmeticSlot.decoration,
    price: 2000,
  ),
  Cosmetic(
    id: 'fountain',
    name: "Çeşme",
    emoji: '⛲',
    slot: CosmeticSlot.decoration,
    price: 5000,
  ),
  Cosmetic(
    id: 'peacock',
    name: "Tavus Kuşu",
    emoji: '🦚',
    slot: CosmeticSlot.decoration,
    price: 8000,
  ),
  Cosmetic(
    id: 'carousel',
    name: "Atlıkarınca",
    emoji: '🎠',
    slot: CosmeticSlot.decoration,
    price: 15000,
  ),
  Cosmetic(
    id: 'ferris-wheel',
    name: "Dönme Dolap",
    emoji: '🎡',
    slot: CosmeticSlot.decoration,
    price: 40000,
  ),
  Cosmetic(
    id: 'straw-hat',
    name: "Hasır Şapka",
    emoji: '👒',
    slot: CosmeticSlot.hat,
    price: 500,
  ),
  Cosmetic(
    id: 'cowboy',
    name: "Kovboy Şapkası",
    emoji: '🤠',
    slot: CosmeticSlot.hat,
    price: 2500,
  ),
  Cosmetic(
    id: 'top-hat',
    name: "Silindir Şapka",
    emoji: '🎩',
    slot: CosmeticSlot.hat,
    price: 7500,
  ),
  Cosmetic(
    id: 'crown',
    name: "Çiftlik Tacı",
    emoji: '👑',
    slot: CosmeticSlot.hat,
    price: 30000,
  ),
];

Cosmetic cosmeticById(String id) => cosmetics.firstWhere((c) => c.id == id);
