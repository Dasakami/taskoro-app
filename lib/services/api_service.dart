import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Исключение API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

/// Центральный сервис для всех API запросов
class ApiService {
  // API конфигурация
  static const String baseUrl = 'http://10.36.46.53:8000/api';
  static const String authUrl = 'http://10.36.46.53:8000';
  
  // Ключи хранилища
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  
  // Токены
  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  
  // Состояние
  bool _isRefreshing = false;
  final List<Future<void> Function()> _pendingRequests = [];
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // ===================== ИНИЦИАЛИЗАЦИЯ =====================
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _userId = prefs.getInt(_userIdKey);
  }
  
  // ===================== УПРАВЛЕНИЕ ТОКЕНАМИ =====================
  
  Future<void> setTokens(String accessToken, String refreshToken, {int? userId}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    }
  }
  
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _isRefreshing = false;
    _pendingRequests.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }
  
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  bool get isAuthenticated => _accessToken != null && _refreshToken != null;
  
  // ===================== ХЕДЕРЫ =====================
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };
  
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };
  
  // ===================== ОБРАБОТКА ЗАПРОСОВ =====================
  
  /// Выполнить GET запрос и вернуть декодированные данные
  Future<dynamic> get(String path, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await _handleRequest(() => http.get(
      url,
      headers: auth ? _authHeaders : _headers,
    ));
    return _decodeResponse(response);
  }
  
  /// Выполнить POST запрос и вернуть декодированные данные
  Future<dynamic> post(
    String path,
    {dynamic body, bool auth = true}
  ) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await _handleRequest(() => http.post(
      url,
      headers: auth ? _authHeaders : _headers,
      body: jsonEncode(body ?? {}),
    ));
    return _decodeResponse(response);
  }
  
  /// Выполнить PUT запрос и вернуть декодированные данные
  Future<dynamic> put(
    String path,
    {dynamic body, bool auth = true}
  ) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await _handleRequest(() => http.put(
      url,
      headers: auth ? _authHeaders : _headers,
      body: jsonEncode(body ?? {}),
    ));
    return _decodeResponse(response);
  }
  
  /// Выполнить PATCH запрос и вернуть декодированные данные
  Future<dynamic> patch(
    String path,
    {dynamic body, bool auth = true}
  ) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await _handleRequest(() => http.patch(
      url,
      headers: auth ? _authHeaders : _headers,
      body: jsonEncode(body ?? {}),
    ));
    return _decodeResponse(response);
  }
  
  /// Выполнить DELETE запрос и вернуть декодированные данные
  Future<dynamic> delete(String path, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await _handleRequest(() => http.delete(
      url,
      headers: auth ? _authHeaders : _headers,
    ));
    return _decodeResponse(response);
  }
  
  /// Логин - специальный запрос, возвращает декодированные данные
  Future<dynamic> login(String username, String password) async {
    final url = Uri.parse('$authUrl/api/token/');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    return _decodeResponse(response);
  }
  
  // ===================== ПРИВАТНЫЕ МЕТОДЫ =====================
  
  Future<http.Response> _handleRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      var response = await request();
      
      // Автоматическое обновление токена при 401
      if (response.statusCode == 401 && _refreshToken != null) {
        if (_isRefreshing) {
          // Ждём пока токен обновится
          await _waitForTokenRefresh();
          return await _handleRequest(request);
        }
        
        _isRefreshing = true;
        try {
          await _refreshAccessToken();
          _isRefreshing = false;
          return await _handleRequest(request);
        } catch (e) {
          _isRefreshing = false;
          await clearTokens();
          rethrow;
        }
      }
      
      return response;
    } catch (e) {
      throw ApiException('Ошибка сети: $e');
    }
  }
  
  Future<void> _waitForTokenRefresh() async {
    final completer = Completer<void>();
    _pendingRequests.add(() async => completer.complete());
    await completer.future;
  }
  
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw ApiException('Refresh token отсутствует');
    }
    
    try {
      final response = await http.post(
        Uri.parse('$authUrl/api/token/refresh/'),
        headers: _headers,
        body: jsonEncode({'refresh': _refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken!);
        
        // Выполнить отложенные запросы
        for (final req in _pendingRequests) {
          await req();
        }
        _pendingRequests.clear();
      } else {
        await clearTokens();
        throw ApiException('Не удалось обновить токен');
      }
    } catch (e) {
      await clearTokens();
      throw ApiException('Ошибка обновления токена: $e');
    }
  }
  
  /// Декодировать ответ сервера в список или карту
  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      
      try {
        final decoded = jsonDecode(response.body);
        return decoded;
      } catch (e) {
        throw ApiException('Ошибка декодирования ответа: $e');
      }
    } else {
      throw ApiException(
        'Ошибка сервера: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}