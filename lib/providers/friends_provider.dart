import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:taskoro/providers/user_provider.dart';

import '../models/friends_model.dart'; // Friend и FriendRequest модели

class FriendsProvider with ChangeNotifier {
  late UserProvider _userProvider;

  FriendsProvider(this._userProvider);

  // --- Запросы в друзья ---
  bool _isLoadingRequests = false;
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];

  bool get isLoadingRequests => _isLoadingRequests;
  List<FriendRequest> get receivedRequests => _receivedRequests;
  List<FriendRequest> get sentRequests => _sentRequests;

  // --- Друзья ---
  List<Friend> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  set userProvider(UserProvider provider) {
    _userProvider = provider;
  }

  // Загрузка списка друзей
  Future<void> fetchFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = _userProvider.accessToken;
    if (token == null) {
      _error = 'Пользователь не авторизован';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _friends = data.map((e) => Friend.fromJson(e)).toList();
      } else {
        _error = 'Ошибка загрузки друзей: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Ошибка: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Загрузка входящих и исходящих запросов в друзья
  Future<void> fetchFriendRequests() async {
    _isLoadingRequests = true;
    notifyListeners();

    final token = _userProvider.accessToken;
    if (token == null) {
      _receivedRequests = [];
      _sentRequests = [];
      _isLoadingRequests = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/requests/');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

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
    }

    _isLoadingRequests = false;
    notifyListeners();
  }

  // Принять запрос в друзья
  Future<void> acceptFriendRequest(int requestId) async {
    final token = _userProvider.accessToken;
    if (token == null) return;

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/requests/$requestId/accept/');
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      _receivedRequests.removeWhere((r) => r.id == requestId);
      await fetchFriends(); // обновить список друзей
      notifyListeners();
    } else {
      print('Ошибка принятия запроса: ${response.statusCode}');
    }
  }

  // Отклонить запрос в друзья
  Future<void> declineFriendRequest(int requestId) async {
    final token = _userProvider.accessToken;
    if (token == null) return;

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/requests/$requestId/decline/');
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      _receivedRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } else {
      print('Ошибка отклонения запроса: ${response.statusCode}');
    }
  }

  // Поиск пользователей (по нику или id)
  bool _isSearching = false;
  List<Friend> _searchResults = [];

  bool get isSearching => _isSearching;
  List<Friend> get searchResults => _searchResults;

  Future<List<Friend>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final token = _userProvider.accessToken;
    if (token == null) return [];

    final url = Uri.parse('https://taskoro.onrender.com/api/users/search/?q=$query');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Friend.fromJson(e)).toList();
      }
    } catch (e) {
      print('Ошибка поиска пользователей: $e');
    }

    return [];
  }

  // Отправка запроса в друзья
  Future<bool> sendFriendRequest(int userId) async {
    final token = _userProvider.accessToken;
    if (token == null) return false;

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/request/send/$userId/');
    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'user_id': userId}));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Ошибка отправки запроса: ${response.statusCode}');
      return false;
    }
  }

  // Добавим методы для отмены исходящих запросов и удаления друга

// Отмена исходящего запроса (если API есть)
  Future<bool> cancelFriendRequest(int requestId) async {
    final token = _userProvider.accessToken;
    if (token == null) return false;

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/request/decline/$requestId/');
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      _sentRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      return true;
    } else {
      print('Ошибка отмены запроса: ${response.statusCode}');
      return false;
    }
  }

// Удаление друга
  Future<bool> removeFriend(int userId) async {
    final token = _userProvider.accessToken;
    if (token == null) return false;

    final url = Uri.parse('https://taskoro.onrender.com/api/friends/friend/remove/$userId/');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 204) {
      _friends.removeWhere((f) => f.id == userId);
      notifyListeners();
      return true;
    } else {
      print('Ошибка удаления друга: ${response.statusCode}');
      return false;
    }
  }

}
