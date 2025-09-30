
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String currency;
  final int price;
  final String? imageUrl;
  final String? titleText;
  final double? boostMultiplier;
  final int? boostDuration;
  final bool isAvailable;
  final DateTime createdAt;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.currency,
    required this.price,
    this.imageUrl,
    this.titleText,
    this.boostMultiplier,
    this.boostDuration,
    required this.isAvailable,
    required this.createdAt,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      currency: json['currency'] ?? 'coins',
      price: json['price'] ?? 0,
      imageUrl: json['image_url'],
      titleText: json['title_text'],
      boostMultiplier: json['boost_multiplier']?.toDouble(),
      boostDuration: json['boost_duration'],
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Purchase {
  final String id;
  final ShopItem item;
  final int quantity;
  final int totalPrice;
  final DateTime purchasedAt;
  final bool isEquipped;

  Purchase({
    required this.id,
    required this.item,
    required this.quantity,
    required this.totalPrice,
    required this.purchasedAt,
    required this.isEquipped,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'].toString(),
      item: ShopItem.fromJson(json['item']),
      quantity: json['quantity'] ?? 1,
      totalPrice: json['total_price'] ?? 0,
      purchasedAt: DateTime.parse(json['purchased_at']),
      isEquipped: json['is_equipped'] ?? false,
    );
  }
}

class ActiveBoost {
  final String id;
  final ShopItem boostItem;
  final double multiplier;
  final DateTime activatedAt;
  final DateTime expiresAt;
  final bool isActive;

  ActiveBoost({
    required this.id,
    required this.boostItem,
    required this.multiplier,
    required this.activatedAt,
    required this.expiresAt,
    required this.isActive,
  });

  factory ActiveBoost.fromJson(Map<String, dynamic> json) {
    return ActiveBoost(
      id: json['id'].toString(),
      boostItem: ShopItem.fromJson(json['boost_item']),
      multiplier: json['multiplier']?.toDouble() ?? 1.0,
      activatedAt: DateTime.parse(json['activated_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] ?? false,
    );
  }
}

class Chest {
  final String id;
  final String name;
  final String description;
  final int priceCoins;
  final int priceGems;
  final int minCoinsReward;
  final int maxCoinsReward;
  final int minGemsReward;
  final int maxGemsReward;
  final String? imageUrl;

  Chest({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCoins,
    required this.priceGems,
    required this.minCoinsReward,
    required this.maxCoinsReward,
    required this.minGemsReward,
    required this.maxGemsReward,
    this.imageUrl,
  });

  factory Chest.fromJson(Map<String, dynamic> json) {
    return Chest(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceCoins: json['price_coins'] ?? 0,
      priceGems: json['price_gems'] ?? 0,
      minCoinsReward: json['min_coins_reward'] ?? 0,
      maxCoinsReward: json['max_coins_reward'] ?? 0,
      minGemsReward: json['min_gems_reward'] ?? 0,
      maxGemsReward: json['max_gems_reward'] ?? 0,
      imageUrl: json['image_url'],
    );
  }
}

class ChestOpening {
  final String id;
  final Chest chest;
  final int coinsReward;
  final int gemsReward;
  final DateTime openedAt;

  ChestOpening({
    required this.id,
    required this.chest,
    required this.coinsReward,
    required this.gemsReward,
    required this.openedAt,
  });

  factory ChestOpening.fromJson(Map<String, dynamic> json) {
    return ChestOpening(
      id: json['id'].toString(),
      chest: Chest.fromJson(json['chest']),
      coinsReward: json['coins_reward'] ?? 0,
      gemsReward: json['gems_reward'] ?? 0,
      openedAt: DateTime.parse(json['opened_at']),
    );
  }
}
