import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import 'user_provider.dart';

class ShopProvider with ChangeNotifier {
  final UserProvider userProvider;
  final String baseUrl;

  ShopProvider({
    required this.userProvider,
    this.baseUrl = 'http://192.168.1.64:8000',
  });

  // --- Состояние магазина ---
  List<ShopItem> _shopItems = [];
  List<Chest> _chests = [];
  List<InventoryItem> _inventory = [];
  List<Purchase> _purchaseHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ShopItem> get shopItems => _shopItems;
  List<Chest> get chests => _chests;
  List<InventoryItem> get inventory => _inventory;
  List<Purchase> get purchaseHistory => _purchaseHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Фильтрация по категориям
  List<ShopItem> getItemsByType(ItemType type) {
    return _shopItems.where((item) => item.type == type && item.isAvailable).toList();
  }

  List<ShopItem> getItemsByRarity(ItemRarity rarity) {
    return _shopItems.where((item) => item.rarity == rarity && item.isAvailable).toList();
  }

  List<ShopItem> get featuredItems {
    return _shopItems.where((item) => item.hasDiscount || item.rarity == ItemRarity.legendary).toList();
  }

  // Вспомогательные методы
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (userProvider.accessToken != null) {
      headers['Authorization'] = 'Bearer ${userProvider.accessToken}';
    }

    return headers;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Загрузка товаров магазина
  Future<void> fetchShopItems() async {
    if (userProvider.accessToken == null) {
      _setError('Пользователь не авторизован');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/shop/shop-items/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _shopItems = data.map((e) => ShopItem.fromJson(e)).toList();
        _setError(null);
      } else {
        _setError('Ошибка загрузки товаров: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Загрузка сундуков
  Future<void> fetchChests() async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/shop/chests/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _chests = data.map((e) => Chest.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки сундуков: $e');
    }
  }

  // Загрузка инвентаря
  Future<void> fetchInventory() async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/shop/purchases/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _inventory = data.map((e) => InventoryItem.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки инвентаря: $e');
    }
  }

  // Загрузка истории покупок
  Future<void> fetchPurchaseHistory() async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/shop/purchases/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _purchaseHistory = data.map((e) => Purchase.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки истории покупок: $e');
    }
  }

  // Покупка товара
  Future<bool> purchaseItem(ShopItem item, {int quantity = 1}) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/shop/purchases/');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'item_id': item.id,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        // Обновляем данные пользователя и инвентарь
        await fetchInventory();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _setError(errorData['detail'] ?? 'Ошибка покупки');
        return false;
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
      return false;
    }
  }

  // Покупка сундука
  Future<bool> purchaseChest(Chest chest) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/shop/chest-openings/');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'chest_id': chest.id,
        }),
      );

      if (response.statusCode == 201) {
        await fetchInventory();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _setError(errorData['detail'] ?? 'Ошибка покупки сундука');
        return false;
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
      return false;
    }
  }

  // Проверка, достаточно ли средств для покупки
  bool canAfford(ShopItem item, {int quantity = 1}) {
    final user = userProvider.user;
    if (user == null) return false;

    final totalPrice = item.finalPrice * quantity;

    if (item.currency == 'coins') {
      return user.coins >= totalPrice;
    } else if (item.currency == 'gems') {
      return user.gems >= totalPrice;
    }

    return false;
  }

  bool canAffordChest(Chest chest) {
    final user = userProvider.user;
    if (user == null) return false;

    if (chest.currency == 'coins') {
      return user.coins >= chest.price;
    } else if (chest.currency == 'gems') {
      return user.gems >= chest.price;
    }

    return false;
  }

  // Демо данные
  void initDemoData() {
    _shopItems = [
      ShopItem(
        id: 1,
        name: 'Золотая корона',
        description: 'Роскошная корона для настоящих победителей',
        price: 500,
        currency: 'coins',
        type: ItemType.avatar,
        rarity: ItemRarity.legendary,
      ),
      ShopItem(
        id: 2,
        name: 'Усиление опыта',
        description: 'Увеличивает получаемый опыт на 50% на 24 часа',
        price: 100,
        currency: 'gems',
        type: ItemType.boost,
        rarity: ItemRarity.rare,
      ),
      ShopItem(
        id: 3,
        name: 'Магический посох',
        description: 'Красивый посох для украшения профиля',
        price: 200,
        currency: 'coins',
        type: ItemType.decoration,
        rarity: ItemRarity.epic,
        discountPercent: 25,
        discountEndDate: DateTime.now().add(const Duration(days: 3)),
      ),
      ShopItem(
        id: 4,
        name: 'Темная тема',
        description: 'Стильная темная тема для приложения',
        price: 300,
        currency: 'coins',
        type: ItemType.theme,
        rarity: ItemRarity.rare,
      ),
    ];

    _chests = [
      Chest(
        id: 1,
        name: 'Обычный сундук',
        description: 'Содержит базовые награды',
        price: 50,
        currency: 'coins',
        possibleRewards: [],
      ),
      Chest(
        id: 2,
        name: 'Легендарный сундук',
        description: 'Гарантированно содержит редкие предметы',
        price: 250,
        currency: 'gems',
        possibleRewards: [],
      ),
    ];

    _inventory = [
      InventoryItem(
        id: 1,
        item: _shopItems[1],
        quantity: 2,
        acquiredAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    notifyListeners();
  }

  // Очистка данных
  void clearData() {
    _shopItems.clear();
    _chests.clear();
    _inventory.clear();
    _purchaseHistory.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}