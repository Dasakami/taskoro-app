import 'package:flutter/material.dart';

enum ItemType {
  avatar,
  boost,
  decoration,
  theme,
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
      case ItemType.avatar:
        return 'Аватар';
      case ItemType.boost:
        return 'Усиление';
      case ItemType.decoration:
        return 'Декорация';
      case ItemType.theme:
        return 'Тема';
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
      type: _itemTypeFromString(json['type'] ?? 'decoration'),
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
      case 'avatar':
        return ItemType.avatar;
      case 'boost':
        return ItemType.boost;
      case 'decoration':
        return ItemType.decoration;
      case 'theme':
        return ItemType.theme;
      case 'equipment':
        return ItemType.equipment;
      default:
        return ItemType.decoration;
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
  final int price;
  final String currency;
  final String? imageUrl;
  final List<ChestReward> possibleRewards;
  final bool isAvailable;

  Chest({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
    required this.possibleRewards,
    this.isAvailable = true,
  });

  factory Chest.fromJson(Map<String, dynamic> json) {
    return Chest(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'coins',
      imageUrl: json['image_url'],
      possibleRewards: (json['possible_rewards'] as List? ?? [])
          .map((e) => ChestReward.fromJson(e))
          .toList(),
      isAvailable: json['is_available'] ?? true,
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