/// Anything that can be kept in the barn and sold: a crop or an animal's
/// product.
abstract interface class FarmGood {
  /// Saved with the farm; never change it once released.
  String get id;
  String get name;
  String get emoji;

  /// Coins one unit sells for at the market.
  int get price;
}

/// Something to grow. Each field gives a few of it at harvest.
class Crop implements FarmGood {
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

  @override
  final String id;
  @override
  final String name;
  @override
  final String emoji;

  /// Farm level that unlocks it.
  final int level;
  final int seedCost;
  final Duration growTime;

  @override
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

/// What an animal gives once it has eaten.
class AnimalProduct implements FarmGood {
  const AnimalProduct({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String emoji;
  @override
  final int price;
}

/// A kind of farm animal. It eats crops from the barn and, after [time],
/// leaves one [product] to collect.
class Animal {
  const Animal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.home,
    required this.level,
    required this.price,
    required this.feedId,
    required this.feedCount,
    required this.time,
    required this.product,
    required this.xp,
  });

  /// Saved with the farm; never change it once released.
  final String id;
  final String name;
  final String emoji;

  /// Where these animals live, e.g. "Kümes".
  final String home;

  /// Farm level that unlocks it.
  final int level;

  /// Coins for the first one; every further one costs this much more.
  final int price;

  /// The crop it eats, and how many per meal.
  final String feedId;
  final int feedCount;

  /// How long it takes to make its product after a meal.
  final Duration time;
  final AnimalProduct product;

  /// Experience for collecting one product.
  final int xp;

  Crop get feed => cropById(feedId);
}

/// Animals from cheap and quick to dear and slow. Each eats a crop the
/// player has already unlocked by the time it is.
const List<Animal> animals = [
  Animal(
    id: 'chicken',
    name: "Tavuk",
    emoji: '🐔',
    home: "Kümes",
    level: 2,
    price: 40,
    feedId: 'wheat',
    feedCount: 1,
    time: Duration(minutes: 2),
    product: AnimalProduct(id: 'egg', name: "Yumurta", emoji: '🥚', price: 9),
    xp: 2,
  ),
  Animal(
    id: 'cow',
    name: "İnek",
    emoji: '🐄',
    home: "Ahır",
    level: 4,
    price: 200,
    feedId: 'corn',
    feedCount: 2,
    time: Duration(minutes: 5),
    product: AnimalProduct(id: 'milk', name: "Süt", emoji: '🥛', price: 60),
    xp: 6,
  ),
  Animal(
    id: 'sheep',
    name: "Koyun",
    emoji: '🐑',
    home: "Ağıl",
    level: 6,
    price: 600,
    feedId: 'tomato',
    feedCount: 2,
    time: Duration(minutes: 12),
    product: AnimalProduct(id: 'wool', name: "Yün", emoji: '🧶', price: 140),
    xp: 14,
  ),
  Animal(
    id: 'bee',
    name: "Arı",
    emoji: '🐝',
    home: "Kovan",
    level: 9,
    price: 1500,
    feedId: 'strawberry',
    feedCount: 2,
    time: Duration(minutes: 30),
    product: AnimalProduct(id: 'honey', name: "Bal", emoji: '🍯', price: 320),
    xp: 30,
  ),
];

Animal animalById(String id) => animals.firstWhere((a) => a.id == id);

/// Everything the barn can hold, crops first.
final List<FarmGood> farmGoods = [
  ...crops,
  for (final animal in animals) animal.product,
];

FarmGood goodById(String id) => farmGoods.firstWhere((good) => good.id == id);

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

  /// Collect from and feed every animal at once.
  tendAll,

  /// Every animal gives more of its product.
  moreProducts,

  /// Animals make their products faster.
  fasterAnimals,

  /// Animals eat less per meal.
  lessFeed,

  /// Lucky doubles come more often.
  luckier,

  /// Seeds cost less.
  cheaperSeeds,

  /// Neighbours pay more for their orders.
  betterOrders,
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
    id: 'feeder',
    name: "Otomatik Yemlik",
    emoji: '🥣',
    description: "Hayvanların ürünlerini toplar, açları tek dokunuşla besler.",
    level: 5,
    price: 500,
    effect: ToolEffect.tendAll,
  ),
  FarmTool(
    id: 'seed-store',
    name: "Tohum Ambarı",
    emoji: '🌰',
    description: "Tohumlar yarı fiyatına gelir.",
    level: 5,
    price: 700,
    effect: ToolEffect.cheaperSeeds,
    amount: 0.5,
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
    id: 'barn-radio',
    name: "Ahır Radyosu",
    emoji: '📻',
    description: "Müzik dinleyen hayvanlar %25 daha hızlı ürün verir.",
    level: 6,
    price: 1200,
    effect: ToolEffect.fasterAnimals,
    amount: 0.25,
  ),
  FarmTool(
    id: 'milking-kit',
    name: "Sağım ve Toplama Seti",
    emoji: '🧺',
    description: "Her hayvan bir ürün fazla verir.",
    level: 7,
    price: 2000,
    effect: ToolEffect.moreProducts,
    amount: 1,
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
    id: 'feed-silo',
    name: "Yem Silosu",
    emoji: '🛢️',
    description: "Hayvanlar her öğünde bir yem eksik yer.",
    level: 9,
    price: 3000,
    effect: ToolEffect.lessFeed,
    amount: 1,
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
    id: 'truck',
    name: "Nakliye Kamyoneti",
    emoji: '🚚',
    description: "Siparişlerden %30 daha çok para gelir.",
    level: 11,
    price: 4500,
    effect: ToolEffect.betterOrders,
    amount: 0.3,
  ),
  FarmTool(
    id: 'clover',
    name: "Dört Yapraklı Yonca",
    emoji: '🍀',
    description: "Bereketli hasat ve bereketli ürün şansı iki katına çıkar.",
    level: 12,
    price: 5000,
    effect: ToolEffect.luckier,
    amount: 0.1,
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
  FarmTool(
    id: 'modern-barn',
    name: "Modern Ahır",
    emoji: '🏛️',
    description: "Her hayvan bir ürün daha fazla verir.",
    level: 15,
    price: 12000,
    effect: ToolEffect.moreProducts,
    amount: 1,
  ),
];
