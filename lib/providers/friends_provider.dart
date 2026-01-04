import 'package:flutter/material.dart';
import '../models/friends_model.dart';
import '../services/api_service.dart';

/// Провайдер для управления друзьями и запросами в друзья
class FriendsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Данные друзей
  List<Friend> _friends = [];
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];
  
  // Состояние
  bool _isLoading = false;
  bool _isLoadingRequests = false;
  String? _error;
  
  // ===================== GETTERS =====================
  
  List<Friend> get friends => _friends;
  List<FriendRequest> get receivedRequests => _receivedRequests;
  List<FriendRequest> get sentRequests => _sentRequests;
  
  bool get isLoading => _isLoading;
  bool get isLoadingRequests => _isLoadingRequests;
  String? get error => _error;
  
  int get pendingRequestsCount => _receivedRequests.length;
  int get friendsCount => _friends.length;
  
  // ===================== УПРАВЛЕНИЕ ДРУЗЬЯМИ =====================
  
  /// Получить список друзей
  Future<void> fetchFriends() async {
    if (!_api.isAuthenticated) {
      _setError('Не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/friends/');
      
      if (data is List) {
        _friends = data
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['friends'] as List? ?? [];
        _friends = list
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      _error = null;
    } catch (e) {
      _setError('Ошибка загрузки друзей: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Получить профиль пользователя по ID
  Future<Friend> fetchUserProfile(int userId) async {
    try {
      final data = await _api.get('/users/users/$userId/');
      return Friend.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException('Профиль не найден: $e');
    }
  }
  
  /// Удалить друга
  Future<bool> removeFriend(int userId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.delete('/friends/remove/$userId/');
      _friends.removeWhere((f) => f.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка удаления друга: $e');
      return false;
    }
  }
  
  // ===================== ЗАПРОСЫ В ДРУЗЬЯ =====================
  
  /// Получить запросы в друзья (отправленные и полученные)
  Future<void> fetchFriendRequests() async {
    if (!_api.isAuthenticated) {
      _receivedRequests = [];
      _sentRequests = [];
      notifyListeners();
      return;
    }
    
    _isLoadingRequests = true;
    notifyListeners();
    
    try {
      final data = await _api.get('/friends/requests/');
      
      if (data is Map<String, dynamic>) {
        // Полученные запросы
        final received = data['received_requests'] as List? ?? [];
        _receivedRequests = received
            .map((e) => FriendRequest.fromJson(
              e as Map<String, dynamic>,
              isReceived: true,
            ))
            .toList();
        
        // Отправленные запросы
        final sent = data['sent_requests'] as List? ?? [];
        _sentRequests = sent
            .map((e) => FriendRequest.fromJson(
              e as Map<String, dynamic>,
              isReceived: false,
            ))
            .toList();
        
        // Загрузить информацию о пользователях если нужно
        await _enrichFriendRequests();
      }
      
      _error = null;
    } catch (e) {
      _setError('Ошибка загрузки запросов: $e');
      _receivedRequests = [];
      _sentRequests = [];
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }
  
  /// Внутренний метод для загрузки информации о пользователях в запросах
  Future<void> _enrichFriendRequests() async {
    try {
      // Загружаем информацию о пользователях для полученных запросов
      for (var i = 0; i < _receivedRequests.length; i++) {
        final req = _receivedRequests[i];
        if (req.username == 'Unknown' && req.userId != 0) {
          try {
            final user = await fetchUserProfile(req.userId);
            _receivedRequests[i] = req.copyWith(
              username: user.username,
              level: user.level,
            );
          } catch (_) {
            // Игнорируем ошибки загрузки отдельных профилей
          }
        }
      }
      
      // Загружаем информацию о пользователях для отправленных запросов
      for (var i = 0; i < _sentRequests.length; i++) {
        final req = _sentRequests[i];
        if (req.username == 'Unknown' && req.userId != 0) {
          try {
            final user = await fetchUserProfile(req.userId);
            _sentRequests[i] = req.copyWith(
              username: user.username,
              level: user.level,
            );
          } catch (_) {
            // Игнорируем ошибки загрузки отдельных профилей
          }
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки информации о пользователях: $e');
    }
  }
  
  /// Отправить запрос в друзья
  Future<bool> sendFriendRequest(int userId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/friends/request/send/', body: {'user_id': userId});
      await fetchFriendRequests();
      return true;
    } catch (e) {
      _setError('Ошибка отправки запроса: $e');
      return false;
    }
  }
  
  /// Принять запрос в друзья
  Future<bool> acceptFriendRequest(int requestId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/friends/request/$requestId/accept/');
      await fetchFriendRequests();
      await fetchFriends();
      return true;
    } catch (e) {
      _setError('Ошибка принятия запроса: $e');
      return false;
    }
  }
  
  /// Отклонить запрос в друзья
  Future<bool> declineFriendRequest(int requestId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/friends/request/$requestId/decline/');
      _receivedRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка отклонения запроса: $e');
      return false;
    }
  }
  
  /// Отменить отправленный запрос
  Future<bool> cancelFriendRequest(int requestId) async {
    if (!_api.isAuthenticated) return false;
    
    try {
      await _api.post('/friends/request/$requestId/cancel/');
      _sentRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка отмены запроса: $e');
      return false;
    }
  }
  
  // ===================== ПОИСК =====================
  
  /// Поиск пользователей
  Future<List<Friend>> searchUsers(String query) async {
    if (query.isEmpty || !_api.isAuthenticated) return [];
    
    try {
      final data = await _api.get('/users/search/?q=$query');
      
      if (data is List) {
        return data
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['results'] as List? ?? [];
        return list
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Ошибка поиска: $e');
      return [];
    }
  }
  
  // ===================== УТИЛИТЫ =====================
  
  /// Очистить все данные
  void clearData() {
    _friends.clear();
    _receivedRequests.clear();
    _sentRequests.clear();
    _error = null;
    _isLoading = false;
    _isLoadingRequests = false;
    notifyListeners();
  }
  
  /// Обновить все данные (друзья и запросы)
  Future<void> refreshAll() async {
    await Future.wait([
      fetchFriends(),
      fetchFriendRequests(),
    ]);
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
