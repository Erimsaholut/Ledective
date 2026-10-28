/// Something to grow. Each field gives a few of it at harvest.
class Crop {
  const Crop({
    required this.id,
    required this.name,
    required this.emoji,
    required this.level,
    required this.seedCost,
    required this.growTime,
    required this.price,
    required this.xp,
  });

  /// Saved with the farm; never change it once released.
  final String id;
  final String name;
  final String emoji;

  /// Farm level that unlocks it.
  final int level;
  final int seedCost;
  final Duration growTime;

  /// Coins one unit sells for at the market.
  final int price;

  /// Experience for harvesting one field of it.
  final int xp;
}

/// Crops from quick and cheap to slow and valuable. Wheat seed is free, so
/// a broke farmer can always start over.
const List<Crop> crops = [
  Crop(
    id: 'wheat',
    name: "Buğday",
    emoji: '🌾',
    level: 1,
    seedCost: 0,
    growTime: Duration(seconds: 30),
    price: 2,
    xp: 1,
  ),
  Crop(
    id: 'carrot',
    name: "Havuç",
    emoji: '🥕',
    level: 2,
    seedCost: 2,
    growTime: Duration(minutes: 1),
    price: 6,
    xp: 2,
  ),
  Crop(
    id: 'corn',
    name: "Mısır",
    emoji: '🌽',
    level: 3,
    seedCost: 4,
    growTime: Duration(minutes: 2),
    price: 14,
    xp: 4,
  ),
  Crop(
    id: 'tomato',
    name: "Domates",
    emoji: '🍅',
    level: 5,
    seedCost: 7,
    growTime: Duration(minutes: 5),
    price: 34,
    xp: 10,
  ),
  Crop(
    id: 'strawberry',
    name: "Çilek",
    emoji: '🍓',
    level: 7,
    seedCost: 12,
    growTime: Duration(minutes: 10),
    price: 70,
    xp: 20,
  ),
  Crop(
    id: 'pumpkin',
    name: "Balkabağı",
    emoji: '🎃',
    level: 9,
    seedCost: 20,
    growTime: Duration(minutes: 30),
    price: 200,
    xp: 60,
  ),
  Crop(
    id: 'sunflower',
    name: "Ayçiçeği",
    emoji: '🌻',
    level: 12,
    seedCost: 35,
    growTime: Duration(hours: 1),
    price: 420,
    xp: 120,
  ),
];

Crop cropById(String id) => crops.firstWhere((crop) => crop.id == id);

/// What an owned farm tool does.
enum ToolEffect {
  /// Crops grow faster.
  faster,

  /// Every field gives one more crop.
  biggerHarvest,

  /// Plant every empty field at once.
  plantAll,

  /// Harvest every ready field at once.
  harvestAll,

  /// The market pays more.
  betterPrices,
}

/// Equipment bought once in the shop and kept for good.
class FarmTool {
  const FarmTool({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.level,
    required this.price,
    required this.effect,
    this.amount = 0,
  });

  /// Saved with the farm; never change it once released.
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int level;
  final int price;
  final ToolEffect effect;

  /// How strong [effect] is, e.g. 0.2 for 20% faster growth.
  final double amount;
}

const List<FarmTool> farmTools = [
  FarmTool(
    id: 'watering-can',
    name: "Sulama Kovası",
    emoji: '🪣',
    description: "Ürünler %20 daha hızlı büyür.",
    level: 2,
    price: 80,
    effect: ToolEffect.faster,
    amount: 0.2,
  ),
  FarmTool(
    id: 'fertilizer',
    name: "Gübre Çuvalı",
    emoji: '🧪',
    description: "Her tarladan bir ürün fazla çıkar.",
    level: 3,
    price: 200,
    effect: ToolEffect.biggerHarvest,
    amount: 1,
  ),
  FarmTool(
    id: 'tractor',
    name: "Traktör",
    emoji: '🚜',
    description: "Bütün boş tarlalara tek dokunuşla ekim yapar.",
    level: 4,
    price: 400,
    effect: ToolEffect.plantAll,
  ),
  FarmTool(
    id: 'harvester',
    name: "Biçerdöver",
    emoji: '⚙️',
    description: "Hazır ürünlerin hepsini tek dokunuşla toplar.",
    level: 6,
    price: 800,
    effect: ToolEffect.harvestAll,
  ),
  FarmTool(
    id: 'sprinkler',
    name: "Fıskiye",
    emoji: '💦',
    description: "Ürünler %30 daha da hızlı büyür.",
    level: 8,
    price: 1500,
    effect: ToolEffect.faster,
    amount: 0.3,
  ),
  FarmTool(
    id: 'market-stall',
    name: "Pazar Tezgâhı",
    emoji: '🏪',
    description: "Pazarda ürünler %25 daha pahalıya satılır.",
    level: 10,
    price: 2500,
    effect: ToolEffect.betterPrices,
    amount: 0.25,
  ),
  FarmTool(
    id: 'greenhouse',
    name: "Sera",
    emoji: '🏡',
    description: "Her tarladan iki ürün daha fazla çıkar.",
    level: 13,
    price: 6000,
    effect: ToolEffect.biggerHarvest,
    amount: 2,
  ),
];
