import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/friends_model.dart';
import 'user_provider.dart';

class FriendsProvider with ChangeNotifier {
  final UserProvider userProvider;
  final String baseUrl;

  FriendsProvider({
    required this.userProvider,
    this.baseUrl = 'http://192.168.1.64:8000',
  });

  // --- Состояние для запросов в друзья ---
  bool _isLoadingRequests = false;
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];

  bool get isLoadingRequests => _isLoadingRequests;
  List<FriendRequest> get receivedRequests => _receivedRequests;
  List<FriendRequest> get sentRequests => _sentRequests;

  // --- Состояние для друзей ---
  List<Friend> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  // Загрузка списка друзей
  Future<void> fetchFriends() async {
    if (userProvider.accessToken == null) {
      _setError('Пользователь не авторизован');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/friends/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _friends = data.map((e) => Friend.fromJson(e)).toList();
        _setError(null);
      } else {
        _setError('Ошибка загрузки друзей: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Загрузка входящих и исходящих запросов в друзья
  Future<void> fetchFriendRequests() async {
    if (userProvider.accessToken == null) {
      _receivedRequests = [];
      _sentRequests = [];
      return;
    }

    _isLoadingRequests = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/friends/requests/');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> received = data['received_requests'] ?? [];
        final List<dynamic> sent = data['sent_requests'] ?? [];

        _receivedRequests = received
            .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>, isReceived: true))
            .toList();

        _sentRequests = sent
            .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>, isReceived: false))
            .toList();
      } else {
        _receivedRequests = [];
        _sentRequests = [];
      }
    } catch (e) {
      _receivedRequests = [];
      _sentRequests = [];
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  // Принять запрос в друзья
  Future<void> acceptFriendRequest(int requestId) async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/friends/request/accept/$requestId/');
      final response = await http.post(url, headers: _headers);

      if (response.statusCode == 200) {
        _receivedRequests.removeWhere((r) => r.id == requestId);
        await fetchFriends(); // обновить список друзей
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка принятия запроса: $e');
    }
  }

  // Отклонить запрос в друзья
  Future<void> declineFriendRequest(int requestId) async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/friends/request/decline/$requestId/');
      final response = await http.post(url, headers: _headers);

      if (response.statusCode == 200) {
        _receivedRequests.removeWhere((r) => r.id == requestId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка отклонения запроса: $e');
    }
  }

  // Поиск пользователей (по нику или id)
  Future<List<Friend>> searchUsers(String query) async {
    if (query.isEmpty || userProvider.accessToken == null) return [];

    try {
      final url = Uri.parse('$baseUrl/api/users/search/?q=$query');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Friend.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Ошибка поиска пользователей: $e');
    }

    return [];
  }

  // Отправка запроса в друзья
  Future<bool> sendFriendRequest(int userId) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/friends/request/send/$userId/');
      final response = await http.post(url, headers: _headers);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Ошибка отправки запроса: $e');
      return false;
    }
  }

  // Отмена исходящего запроса
  Future<bool> cancelFriendRequest(int requestId) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/friends/request/decline/$requestId/');
      final response = await http.post(url, headers: _headers);

      if (response.statusCode == 200) {
        _sentRequests.removeWhere((r) => r.id == requestId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Ошибка отмены запроса: $e');
    }

    return false;
  }

  // Удаление друга
  Future<bool> removeFriend(int userId) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/friends/friend/remove/$userId/');
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _friends.removeWhere((f) => f.id == userId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Ошибка удаления друга: $e');
    }

    return false;
  }

  // Демо данные для тестирования
  void initDemoData() {
    _friends = [
      Friend(
        id: 1,
        username: 'Демо друг 1',
        level: 15,
        experience: 2500,
      ),
      Friend(
        id: 2,
        username: 'Демо друг 2',
        level: 8,
        experience: 1200,
      ),
    ];

    _receivedRequests = [
      FriendRequest(
        id: 1,
        username: 'Новый пользователь',
        level: 5,
      ),
    ];

    _sentRequests = [
      FriendRequest(
        id: 2,
        username: 'Отправленная заявка',
        level: 10,
      ),
    ];

    notifyListeners();
  }

  // Очистка данных
  void clearData() {
    _friends.clear();
    _receivedRequests.clear();
    _sentRequests.clear();
    _error = null;
    _isLoading = false;
    _isLoadingRequests = false;
    notifyListeners();
  }
}