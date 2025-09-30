
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taskoro/providers/user_provider.dart';

import '../models/shop_model.dart';

class ShopProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final String _baseUrl = 'https://daskoro.site/api';
  String? _accessToken;

  ShopProvider({required this.userProvider});

  List<ShopItem> _items = [];
  List<Purchase> _purchases = [];
  List<ActiveBoost> _activeBoosts = [];
  List<Chest> _chests = [];
  List<ChestOpening> _chestOpenings = [];

  bool _isLoading = false;
  String? _error;

  List<ShopItem> get items => _items;
  List<Purchase> get purchases => _purchases;
  List<ActiveBoost> get activeBoosts => _activeBoosts;
  List<Chest> get chests => _chests;
  List<ChestOpening> get chestOpenings => _chestOpenings;
  bool get isLoading => _isLoading;
  String? get error => _error;


  List<Purchase> get userInventory => _purchases;
  List<Purchase> get equippedItems => _purchases.where((p) => p.isEquipped).toList();

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
  };

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Fetch all shop items
  Future<void> fetchShopItems({String? category}) async {
    _setLoading(true);
    _setError(null);

    try {
      String url = '$_baseUrl/shop/items/';
      if (category != null) {
        url += '?category=$category';
      }

      final response = await userProvider.authGet(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _items = data.map((item) => ShopItem.fromJson(item)).toList();
      } else {
        _setError('Ошибка загрузки товаров: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Ошибка соединения: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<ShopItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  Future<bool> purchaseItem(String itemId) async {
    _setLoading(true);
    _setError(null);

    try {

      final response = await userProvider.authPost(Uri.parse('$_baseUrl/shop/purchases/'), body: jsonEncode({'item_id': itemId}), headers: _authHeaders);


      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final purchase = Purchase.fromJson(data);
        _purchases.add(purchase);
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _setError(error['detail'] ?? 'Ошибка покупки');
        return false;
      }
    } catch (e) {
      _setError('Ошибка соединения: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user purchases
  Future<void> fetchUserPurchases() async {
    if (_accessToken == null) return;

    try {
      final response = await userProvider.authGet(Uri.parse('$_baseUrl/shop/purchases/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _purchases = data.map((purchase) => Purchase.fromJson(purchase)).toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('Ошибка загрузки покупок: $e');
    }
  }

  // Equip item
  Future<bool> equipItem(String purchaseId) async {
    try {

      final response = await userProvider.authPost(Uri.parse('$_baseUrl/shop/purchases/$purchaseId/equip/'));


      if (response.statusCode == 200) {
        await fetchUserPurchases(); // Refresh purchases
        return true;
      } else {
        _setError('Ошибка экипировки предмета');
        return false;
      }
    } catch (e) {
      _setError('Ошибка соединения: $e');
      return false;
    }
  }

  // Unequip item
  Future<bool> unequipItem(String purchaseId) async {
    try {
      final response = await userProvider.authPost(Uri.parse('$_baseUrl/shop/purchases/$purchaseId/unequip/'));


      if (response.statusCode == 200) {
        await fetchUserPurchases(); // Refresh purchases
        return true;
      } else {
        _setError('Ошибка снятия предмета');
        return false;
      }
    } catch (e) {
      _setError('Ошибка соединения: $e');
      return false;
    }
  }

  // Fetch active boosts
  Future<void> fetchActiveBoosts() async {
    if (_accessToken == null) return;

    try {

      final response = await userProvider.authGet(Uri.parse('$_baseUrl/shop/boosts/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _activeBoosts = data.map((boost) => ActiveBoost.fromJson(boost)).toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('Ошибка загрузки бустов: $e');
    }
  }

  Future<void> fetchChests() async {
    try {

      final response = await userProvider.authGet(Uri.parse('$_baseUrl/shop/chests/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _chests = data.map((chest) => Chest.fromJson(chest)).toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('Ошибка загрузки сундуков: $e');
    }
  }

  Future<ChestOpening?> openChest(String chestId) async {
    _setLoading(true);
    _setError(null);

    try {

      final response = await userProvider.authPost(Uri.parse('$_baseUrl/shop/chests/$chestId/open/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final opening = ChestOpening.fromJson(data['opening']);
        _chestOpenings.add(opening);
        notifyListeners();
        return opening;
      } else {
        final error = jsonDecode(response.body);
        _setError(error['detail'] ?? 'Ошибка открытия сундука');
        return null;
      }
    } catch (e) {
      _setError('Ошибка соединения: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  bool ownsItem(String itemId) {
    return _purchases.any((purchase) => purchase.item.id == itemId);
  }

  bool isItemEquipped(String itemId) {
    return _purchases.any((purchase) =>
    purchase.item.id == itemId && purchase.isEquipped);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
