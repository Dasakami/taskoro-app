import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../services/api_service.dart';

/// Провайдер для магазина и инвентаря
class ShopProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Данные
  List<ShopItem> _items = [];
  List<Purchase> _purchases = [];
  List<ActiveBoost> _activeBoosts = [];
  List<Chest> _chests = [];
  List<ChestOpening> _chestOpenings = [];
  
  // Состояние
  bool _isLoading = false;
  String? _error;
  
  // ===================== GETTERS =====================
  
  List<ShopItem> get items => _items;
  List<Purchase> get purchases => _purchases;
  List<ActiveBoost> get activeBoosts => _activeBoosts;
  List<Chest> get chests => _chests;
  List<ChestOpening> get chestOpenings => _chestOpenings;
  
  List<Purchase> get inventory => _purchases;
  List<Purchase> get equippedItems => _purchases.where((p) => p.isEquipped).toList();
  List<Purchase> get userInventory => _purchases;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ===================== ЗАГРУЗКА ДАННЫХ =====================
  
  Future<void> fetchShopItems({String? category}) async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      String path = '/shop/items/';
      if (category != null) {
        path += '?category=$category';
      }
      
      final data = await _api.get(path);
      
      if (data is List) {
        _items = data
            .map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['items'] as List? ?? [];
        _items = list
            .map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки товаров: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> fetchUserPurchases() async {
    if (!_api.isAuthenticated) return;
    
    try {
      final data = await _api.get('/shop/purchases/');
      
      if (data is List) {
        _purchases = data
            .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['purchases'] as List? ?? [];
        _purchases = list
            .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки покупок: $e');
    }
  }
  
  Future<void> fetchActiveBoosts() async {
    if (!_api.isAuthenticated) return;
    
    try {
      final data = await _api.get('/shop/boosts/');
      
      if (data is List) {
        _activeBoosts = data
            .map((e) => ActiveBoost.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['boosts'] as List? ?? [];
        _activeBoosts = list
            .map((e) => ActiveBoost.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки бустов: $e');
    }
  }
  
  Future<void> fetchChests() async {
    if (!_api.isAuthenticated) return;
    
    try {
      final data = await _api.get('/shop/chests/');
      
      if (data is List) {
        _chests = data
            .map((e) => Chest.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['chests'] as List? ?? [];
        _chests = list
            .map((e) => Chest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки сундуков: $e');
    }
  }
  
  // ===================== ПОКУПКИ =====================
  
  Future<bool> purchaseItem(String itemId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.post('/shop/purchases/', body: {'item_id': itemId});
      
      if (data is Map<String, dynamic>) {
        final purchase = Purchase.fromJson(data);
        _purchases.add(purchase);
        notifyListeners();
        return true;
      } else {
        throw ApiException('Ошибка покупки');
      }
    } catch (e) {
      _setError('Ошибка покупки: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== ЭКИПИРОВКА =====================
  
  Future<bool> equipItem(String purchaseId) async {
    try {
      await _api.post('/shop/purchases/$purchaseId/equip/');
      await fetchUserPurchases();
      return true;
    } catch (e) {
      _setError('Ошибка экипировки: $e');
      return false;
    }
  }
  
  Future<bool> unequipItem(String purchaseId) async {
    try {
      await _api.post('/shop/purchases/$purchaseId/unequip/');
      await fetchUserPurchases();
      return true;
    } catch (e) {
      _setError('Ошибка снятия предмета: $e');
      return false;
    }
  }
  
  // ===================== СУНДУКИ =====================
  
  Future<ChestOpening?> openChest(String chestId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.post('/shop/chests/$chestId/open/');
      
      if (data is Map<String, dynamic>) {
        final opening = ChestOpening.fromJson(data);
        _chestOpenings.add(opening);
        notifyListeners();
        return opening;
      } else {
        throw ApiException('Ошибка открытия сундука');
      }
    } catch (e) {
      _setError('Ошибка открытия сундука: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== УТИЛИТЫ =====================
  
  List<ShopItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }
  
  bool ownsItem(String itemId) {
    return _purchases.any((purchase) => purchase.item.id == itemId);
  }
  
  bool isItemEquipped(String itemId) {
    return _purchases.any((purchase) =>
        purchase.item.id == itemId && purchase.isEquipped);
  }
  
  void clearData() {
    _items.clear();
    _purchases.clear();
    _activeBoosts.clear();
    _chests.clear();
    _chestOpenings.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
  
  /// Метод для совместимости
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Для совместимости со старым кодом
  void setAccessToken(String? token) {
    // Tokenсохраняютсяautomatically в ApiService
  }
  
  // ===================== ПРИВАТНЫЕ МЕТОДЫ =====================
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
