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
    this.baseUrl = 'http://192.168.220.53:8000',
  });

  // --- Состояние магазина ---
  List<ShopItem> _shopItems = [];
  List<Chest> _chests = [];
  List<InventoryItem> _inventory = [];
  List<Purchase> _purchaseHistory = [];
  bool _isLoading = false;
  String? _error;
  List<ChestReward>? _lastRewards;
  List<ChestReward>? get lastRewards => _lastRewards;

  // Getters
  List<ShopItem> get shopItems => _shopItems;
  List<Chest> get chests => _chests;
  List<InventoryItem> get inventory => _inventory;
  List<Purchase> get purchaseHistory => _purchaseHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  void setLastRewards(List<ChestReward> rewards) {
    _lastRewards = rewards;
    notifyListeners();
  }

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
  // Загрузка инвентаря
  Future<void> fetchInventory() async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/shop/purchases/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> inventoryItemsJson = [];

        for (var element in data) {
          if (element is Map<String, dynamic>) {
            inventoryItemsJson.add(element);
          } else if (element is int) {
            // Элемент типа int — принят как валюта.
            // Если нужно обновить баланс, сделай это здесь.
            // Например, если API возвращает монеты, можно проверить наличие валютного индикатора
            // или обновить баланс напрямую:
            debugPrint("Валюта обнаружена в инвентаре: $element");
            // Если известно, к какой валюте относится число, обнови баланс:
            // userProvider.updateCurrency(coins: element, gems: 0);
          } else {
            debugPrint("Неподходящий тип данных: ${element.runtimeType}");
          }
        }

        _inventory = inventoryItemsJson
            .map((item) => InventoryItem.fromJson(item))
            .toList();

        notifyListeners();
      } else {
        _setError('Ошибка загрузки инвентаря: ${response.statusCode}');
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
  // Покупка сундука
  Future<bool> purchaseChest(Chest chest) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/shop/chest-openings/');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'chest': chest.id,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['rewards'] != null) {
          final rewardsJson = data['rewards'] as List<dynamic>;
          List<ChestReward> rewardList = [];
          // Обработка каждого элемента наград
          for (var reward in rewardsJson) {
            if (reward is int) {
              // Если награда представлена числом, считаем, что это валюта.
              // Используем updateCurrency, чтобы добавить валюту к балансу пользователя.
              if (chest.currency == 'coins') {
                userProvider.updateCurrency(coins: reward, gems: 0);
              } else if (chest.currency == 'gems') {
                userProvider.updateCurrency(coins: 0, gems: reward);
              }
            } else if (reward is Map<String, dynamic>) {
              rewardList.add(ChestReward.fromJson(reward));
            }
          }
          // Если есть обычные предметы (не валюты) — сохраняем их для показа наград в диалоге
          if (rewardList.isNotEmpty) {
            setLastRewards(rewardList);
          }
        }
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
      return user.coins >= chest.price_coins;
    } else if (chest.currency == 'gems') {
      return user.gems >= chest.price_coins;
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
        type: ItemType.avatar_frame,
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
        type: ItemType.background,
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
        type: ItemType.title,
        rarity: ItemRarity.rare,
      ),
    ];

    _chests = [
      Chest(
        id: 1,
        name: 'Обычный сундук',
        description: 'Содержит базовые награды',
        price_coins: 50,
        price_gems: 0,
        currency: 'coins',
        possibleRewards: [],
        isAvailable: false,
        min_coins_reward: 10,
        max_coins_reward: 20,
        min_gems_reward: 0,
        max_gems_reward: 0,
      ),
      Chest(
        id: 2,
        name: 'Легендарный сундук',
        description: 'Гарантированно содержит редкие предметы',
        price_coins: 250,
        price_gems: 0,
        currency: 'gems',
        possibleRewards: [],
        isAvailable: true,
        min_coins_reward: 50,
        max_coins_reward: 100,
        min_gems_reward: 20,
        max_gems_reward: 50,
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


