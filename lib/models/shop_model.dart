import 'package:flutter/material.dart';

enum ItemType {
  avatar_frame,
  title,
  boost,
  background,
  effect,
  equipment,
}

enum ItemRarity {
  common,
  rare,
  epic,
  legendary,
  mythic,
}

class ShopItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String currency; // 'coins' или 'gems'
  final ItemType type;
  final ItemRarity rarity;
  final String? imageUrl;
  final bool isAvailable;
  final int? discountPercent;
  final DateTime? discountEndDate;
  final Map<String, dynamic>? metadata;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
    required this.rarity,
    this.imageUrl,
    this.isAvailable = true,
    this.discountPercent,
    this.discountEndDate,
    this.metadata,
  });

  int get finalPrice {
    if (discountPercent != null && discountEndDate != null && DateTime.now().isBefore(discountEndDate!)) {
      return (price * (100 - discountPercent!) / 100).round();
    }
    return price;
  }

  bool get hasDiscount => discountPercent != null && discountEndDate != null && DateTime.now().isBefore(discountEndDate!);

  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
      case ItemRarity.mythic:
        return Colors.red;
    }
  }

  String get rarityName {
    switch (rarity) {
      case ItemRarity.common:
        return 'Обычный';
      case ItemRarity.rare:
        return 'Редкий';
      case ItemRarity.epic:
        return 'Эпический';
      case ItemRarity.legendary:
        return 'Легендарный';
      case ItemRarity.mythic:
        return 'Мифический';
    }
  }

  String get typeName {
    switch (type) {
      case ItemType.avatar_frame:
        return 'Рамка аватара';
      case ItemType.boost:
        return 'Усиление';
      case ItemType.background:
        return 'Фон профиля';
      case ItemType.title:
        return 'Титул';
        case ItemType.effect:
        return 'Эффект';
      case ItemType.equipment:
        return 'Снаряжение';
    }
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'coins',
      type: _itemTypeFromString(json['type'] ?? 'background'),
      rarity: _itemRarityFromString(json['rarity'] ?? 'common'),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      discountPercent: json['discount_percent'],
      discountEndDate: json['discount_end_date'] != null
          ? DateTime.tryParse(json['discount_end_date'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type.name,
      'rarity': rarity.name,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'discount_percent': discountPercent,
      'discount_end_date': discountEndDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  static ItemType _itemTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'avatar_frame':
        return ItemType.avatar_frame;
      case 'boost':
        return ItemType.boost;
      case 'background':
        return ItemType.background;
      case 'title':
        return ItemType.title;
      case 'equipment':
        return ItemType.equipment;
      default:
        return ItemType.background;
    }
  }

  static ItemRarity _itemRarityFromString(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return ItemRarity.common;
      case 'rare':
        return ItemRarity.rare;
      case 'epic':
        return ItemRarity.epic;
      case 'legendary':
        return ItemRarity.legendary;
      case 'mythic':
        return ItemRarity.mythic;
      default:
        return ItemRarity.common;
    }
  }
}

class Chest {
  final int id;
  final String name;
  final String description;
  final int price_coins;
  final int price_gems;
  final String currency;
  final String? imageUrl;
  final List<ChestReward> possibleRewards;
  final bool isAvailable;
  final int min_coins_reward;
  final int max_coins_reward;
  final int min_gems_reward;
  final int max_gems_reward;

  Chest({
    required this.id,
    required this.name,
    required this.description,
    required this.price_coins,
    required this.price_gems,
    required this.currency,
    this.imageUrl,
    required this.possibleRewards,
    this.isAvailable = true,
    required this.min_coins_reward,
    required this.max_coins_reward,
    required this.min_gems_reward,
    required this.max_gems_reward,
  });

  factory Chest.fromJson(Map<String, dynamic> json) {
    return Chest(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price_coins: json['price'] ?? 0,
      price_gems: json['price'] ?? 0,
      currency: json['currency'] ?? 'coins',
      imageUrl: json['image_url'],
      possibleRewards: (json['possible_rewards'] as List? ?? [])
          .map((e) => ChestReward.fromJson(e))
          .toList(),
      isAvailable: json['is_available'] ?? true,
      min_coins_reward: json['min_coins_reward'] ?? 0,
      max_coins_reward: json['max_coins_reward'] ?? 0,
      min_gems_reward: json['min_gems_reward'] ?? 0,
      max_gems_reward: json['max_gems_reward'] ?? 0,
    );
  }
}

class ChestReward {
  final int itemId;
  final String itemName;
  final ItemRarity rarity;
  final double dropChance;
  final int minQuantity;
  final int maxQuantity;

  ChestReward({
    required this.itemId,
    required this.itemName,
    required this.rarity,
    required this.dropChance,
    required this.minQuantity,
    required this.maxQuantity,
  });

  factory ChestReward.fromJson(Map<String, dynamic> json) {
    return ChestReward(
      itemId: json['item_id'],
      itemName: json['item_name'] ?? '',
      rarity: ShopItem._itemRarityFromString(json['rarity'] ?? 'common'),
      dropChance: (json['drop_chance'] ?? 0.0).toDouble(),
      minQuantity: json['min_quantity'] ?? 1,
      maxQuantity: json['max_quantity'] ?? 1,
    );
  }
}

class InventoryItem {
  final int id;
  final ShopItem item;
  final int quantity;
  final DateTime acquiredAt;
  final bool isEquipped;

  InventoryItem({
    required this.id,
    required this.item,
    required this.quantity,
    required this.acquiredAt,
    this.isEquipped = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      item: ShopItem.fromJson(json['item']),
      quantity: json['quantity'] ?? 1,
      acquiredAt: DateTime.parse(json['acquired_at']),
      isEquipped: json['is_equipped'] ?? false,
    );
  }
}

class Purchase {
  final int id;
  final ShopItem item;
  final int quantity;
  final int totalPrice;
  final String currency;
  final DateTime purchasedAt;
  final String status;

  Purchase({
    required this.id,
    required this.item,
    required this.quantity,
    required this.totalPrice,
    required this.currency,
    required this.purchasedAt,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      item: ShopItem.fromJson(json['item']),
      quantity: json['quantity'] ?? 1,
      totalPrice: json['total_price'] ?? 0,
      currency: json['currency'] ?? 'coins',
      purchasedAt: DateTime.parse(json['purchased_at']),
      status: json['status'] ?? 'completed',
    );
  }
}
