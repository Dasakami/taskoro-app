// providers/friends_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/friends_model.dart';
import 'user_provider.dart';

class FriendsProvider with ChangeNotifier {
  final UserProvider userProvider;
  final String baseUrl;

  FriendsProvider({
    required this.userProvider,
    this.baseUrl = 'https://taskoro.onrender.com',
  });

  // --- State: друзья ---
  List<Friend> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- State: запросы ---
  bool _isLoadingRequests = false;
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];

  bool get isLoadingRequests => _isLoadingRequests;
  List<FriendRequest> get receivedRequests => _receivedRequests;
  List<FriendRequest> get sentRequests => _sentRequests;

  Map<String, String> get _headers {
    final h = {'Content-Type': 'application/json'};
    if (userProvider.accessToken != null) {
      h['Authorization'] = 'Bearer ${userProvider.accessToken}';
    }
    return h;
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // --- CRUD друзей ---
  Future<void> fetchFriends() async {
    if (userProvider.accessToken == null) {
      _setError('Не авторизован');
      return;
    }
    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/friends/');
      final resp = await userProvider.authGet(url);

      debugPrint('fetchFriends => ${resp.statusCode}: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        _friends = data.map((e) => Friend.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _setError('Ошибка ${resp.statusCode}');
      }
    } catch (e) {
      _setError('Сетевая ошибка: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Friend> fetchUserProfile(int userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/');
    final resp = await userProvider.authGet(url);
    debugPrint('fetchUserProfile($userId) => ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode == 200) {
      return Friend.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Профиль не найден');
  }

  Future<bool> removeFriend(int userId) async {
    final url = Uri.parse('$baseUrl/api/friends/friend/remove/$userId/');
    final resp = await userProvider.authDelete(url);

    debugPrint('removeFriend($userId) => ${resp.statusCode}');
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      _friends.removeWhere((f) => f.id == userId);
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Запросы в друзья ---
  Future<void> fetchFriendRequests() async {
    if (userProvider.accessToken == null) {
      _receivedRequests = [];
      _sentRequests = [];
      notifyListeners();
      return;
    }
    _isLoadingRequests = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/friends/requests/');
      final resp = await userProvider.authGet(url);
      debugPrint('fetchFriendRequests => ${resp.statusCode}: ${resp.body}');
      if (resp.statusCode == 200) {
        final map = json.decode(resp.body) as Map<String, dynamic>;
        final recList = (map['received_requests'] as List).cast<Map<String, dynamic>>();
        final sentList = (map['sent_requests']     as List).cast<Map<String, dynamic>>();

        _receivedRequests = recList
            .map((e) => FriendRequest.fromJson(e, isReceived: true))
            .toList();
        _sentRequests = sentList
            .map((e) => FriendRequest.fromJson(e, isReceived: false))
            .toList();

        // дозагружаем отсутствующие userName/level
        for (var i = 0; i < _receivedRequests.length; i++) {
          final fr = _receivedRequests[i];
          if (fr.userId != 0 && fr.username == 'Unknown') {
            try {
              final prof = await fetchUserProfile(fr.userId);
              _receivedRequests[i] = fr.copyWith(
                username: prof.username,
                avatarUrl: prof.avatarUrl,
                level: prof.level,
              );
            } catch (_) {}
          }
        }
        for (var i = 0; i < _sentRequests.length; i++) {
          final fr = _sentRequests[i];
          if (fr.userId != 0 && fr.username == 'Unknown') {
            try {
              final prof = await fetchUserProfile(fr.userId);
              _sentRequests[i] = fr.copyWith(
                username: prof.username,
                avatarUrl: prof.avatarUrl,
                level: prof.level,
              );
            } catch (_) {}
          }
        }
      } else {
        _receivedRequests = [];
        _sentRequests = [];
      }
    } catch (e) {
      debugPrint('Error fetchFriendRequests: $e');
      _receivedRequests = [];
      _sentRequests = [];
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<bool> sendFriendRequest(int userId) async {
    final url = Uri.parse('$baseUrl/api/friends/request/send/$userId/');
    final resp = await userProvider.authPost(url);

    debugPrint('sendFriendRequest($userId) => ${resp.statusCode}: ${resp.body}');
    final ok = resp.statusCode == 200 || resp.statusCode == 201;
    if (ok) await fetchFriendRequests();
    return ok;
  }

  Future<void> acceptFriendRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/api/friends/request/accept/$requestId/');
    final resp = await userProvider.authPost(url);
    debugPrint('acceptFriendRequest($requestId) => ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      await fetchFriendRequests();
      await fetchFriends();
    }
  }

  /// Возвращает true, если заявка успешно отклонена
  Future<bool> declineFriendRequest(int requestId) async {
    if (userProvider.accessToken == null) return false;

    final url = Uri.parse('$baseUrl/api/friends/request/decline/$requestId/');
    final resp = await userProvider.authPost(url);
    debugPrint('declineFriendRequest($requestId) => ${resp.statusCode}: ${resp.body}');

    if (resp.statusCode == 200 || resp.statusCode == 204) {
      _receivedRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      return true;
    }
    return false;
  }


  // providers/friends_provider.dart

  /// Отмена исходящего запроса (decline для sent_requests)
  Future<bool> cancelFriendRequest(int requestId) async {
    if (userProvider.accessToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/friends/request/cancel/$requestId/');
      final response = await userProvider.authPost(url);
      debugPrint('cancelFriendRequest($requestId) => '
          '${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Удаляем из локального списка sentRequests и обновляем UI
        _sentRequests.removeWhere((r) => r.id == requestId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Ошибка отмены запроса: $e');
    }

    return false;
  }


  // --- Утилиты ---
  void clearData() {
    _friends.clear();
    _receivedRequests.clear();
    _sentRequests.clear();
    _error = null;
    _isLoading = false;
    _isLoadingRequests = false;
    notifyListeners();
  }

  // providers/friends_provider.dart
// … остальной код остаётся без изменений …

  // Поиск пользователей (по нику или id)
  Future<List<Friend>> searchUsers(String query) async {
    if (query.isEmpty || userProvider.accessToken == null) return [];

    try {
      final url = Uri.parse('$baseUrl/api/users/search/?q=$query');
      final response = await userProvider.authGet(url);
      debugPrint('searchUsers("$query") => ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((e) => Friend.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Ошибка поиска пользователей: $e');
    }
    return [];
  }


}
