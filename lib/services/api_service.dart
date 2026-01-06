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

/// Центральный сервис для всех API запросов с автообновлением токенов
class ApiService {
  // API конфигурация
  static const String baseUrl = 'http://10.77.141.53:8000/api';
  static const String authUrl = 'http://10.77.141.53:8000';
  
  // Ключи хранилища
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _tokenExpiryKey = 'token_expiry';
  
  // Токены
  String? _accessToken;
  String? _refreshToken;
  int? _userId;
  DateTime? _tokenExpiry;
  
  // Состояние
  bool _isRefreshing = false;
  final List<Completer<void>> _pendingRequests = [];
  
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
    
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.tryParse(expiryStr);
    }
    
    // Проверяем, не истек ли токен
    if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
      // Токен истек, попробуем обновить
      if (_refreshToken != null) {
        try {
          await _refreshAccessToken();
        } catch (e) {
          // Если не удалось обновить, очищаем токены
          await clearTokens();
        }
      }
    }
  }
  
  // ===================== УПРАВЛЕНИЕ ТОКЕНАМИ =====================
  
  Future<void> setTokens(String accessToken, String refreshToken, {int? userId}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (userId != null) _userId = userId;
    
    // Access token живет 15 минут по умолчанию
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenExpiryKey, _tokenExpiry!.toIso8601String());
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    }
  }
  
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _tokenExpiry = null;
    _isRefreshing = false;
    _pendingRequests.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenExpiryKey);
  }
  
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int? get userId => _userId;
  bool get isAuthenticated => _accessToken != null && _refreshToken != null;
  
  /// Проверить, не истек ли токен (с запасом 1 минута)
  bool get _isTokenExpired {
    if (_tokenExpiry == null) return false;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 1)));
  }
  
  // ===================== ХЕДЕРЫ =====================
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };
  
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };
  
  // ===================== ОБРАБОТКА ЗАПРОСОВ =====================
  
  /// Выполнить GET запрос
  Future<dynamic> get(String path, {bool auth = true}) async {
    return await _makeRequest('GET', path, auth: auth);
  }
  
  /// Выполнить POST запрос
  Future<dynamic> post(String path, {dynamic body, bool auth = true}) async {
    return await _makeRequest('POST', path, body: body, auth: auth);
  }
  
  /// Выполнить PUT запрос
  Future<dynamic> put(String path, {dynamic body, bool auth = true}) async {
    return await _makeRequest('PUT', path, body: body, auth: auth);
  }
  
  /// Выполнить PATCH запрос
  Future<dynamic> patch(String path, {dynamic body, bool auth = true}) async {
    return await _makeRequest('PATCH', path, body: body, auth: auth);
  }
  
  /// Выполнить DELETE запрос
  Future<dynamic> delete(String path, {bool auth = true}) async {
    return await _makeRequest('DELETE', path, auth: auth);
  }
  
  /// Логин (специальный метод)
  Future<dynamic> login(String username, String password) async {
    final url = Uri.parse('$authUrl/api/token/');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    return _decodeResponse(response);
  }
  
  // ===================== ВНУТРЕННИЕ МЕТОДЫ =====================
  
  /// Универсальный метод для выполнения запросов
  Future<dynamic> _makeRequest(
    String method,
    String path,
    {dynamic body, bool auth = true}
  ) async {
    // Проверяем токен перед запросом
    if (auth && _isTokenExpired && _refreshToken != null) {
      await _ensureValidToken();
    }
    
    final url = Uri.parse('$baseUrl$path');
    final headers = auth ? _authHeaders : _headers;
    
    try {
      http.Response response;
      
      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw ApiException('Неподдерживаемый метод: $method');
      }
      
      // Если получили 401, пробуем обновить токен
      if (response.statusCode == 401 && auth && _refreshToken != null) {
        await _ensureValidToken();
        // Повторяем запрос с новым токеном
        return await _makeRequest(method, path, body: body, auth: auth);
      }
      
      return _decodeResponse(response);
    } catch (e) {
      throw ApiException('Ошибка сети: $e');
    }
  }
  
  /// Гарантировать валидность токена
  Future<void> _ensureValidToken() async {
    if (_isRefreshing) {
      // Если уже обновляем, ждем завершения
      final completer = Completer<void>();
      _pendingRequests.add(completer);
      await completer.future;
      return;
    }
    
    _isRefreshing = true;
    try {
      await _refreshAccessToken();
      // Уведомляем ожидающие запросы
      for (final completer in _pendingRequests) {
        completer.complete();
      }
      _pendingRequests.clear();
    } catch (e) {
      // Уведомляем об ошибке
      for (final completer in _pendingRequests) {
        completer.completeError(e);
      }
      _pendingRequests.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }
  
  /// Обновить access token используя refresh token
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
        final newAccessToken = data['access'] as String;
        
        // Обновляем только access token, refresh остается прежним
        _accessToken = newAccessToken;
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, newAccessToken);
        await prefs.setString(_tokenExpiryKey, _tokenExpiry!.toIso8601String());
      } else if (response.statusCode == 401) {
        // Refresh token истек
        await clearTokens();
        throw ApiException('Refresh token истек, требуется повторная авторизация');
      } else {
        throw ApiException('Не удалось обновить токен: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Ошибка обновления токена: $e');
    }
  }
  
  /// Декодировать ответ сервера
  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Ошибка декодирования ответа: $e');
      }
    } else if (response.statusCode == 401) {
      throw ApiException('Не авторизован', statusCode: 401);
    } else {
      String message = 'Ошибка сервера: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('detail')) {
          message = data['detail'];
        } else if (data is Map && data.containsKey('error')) {
          message = data['error'];
        }
      } catch (_) {}
      
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}