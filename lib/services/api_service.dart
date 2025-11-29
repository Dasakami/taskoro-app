import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'http://10.58.136.53:8000/api';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  String? _accessToken;
  String? _refreshToken;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }
  
  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
  
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
  
  bool get isAuthenticated => _accessToken != null && _refreshToken != null;
  
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };
  
  Future<http.Response> _handleRequest(
    Future<http.Response> Function() request,
    {bool retry = true}
  ) async {
    try {
      final response = await request();
      
      // Auto-refresh token on 401
      if (response.statusCode == 401 && retry && _refreshToken != null) {
        await _refreshAccessToken();
        return await _handleRequest(request, retry: false);
      }
      
      return response;
    } catch (e) {
      throw ApiException('Ошибка сети: $e');
    }
  }
  
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw ApiException('Refresh token отсутствует');
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken!);
      } else {
        await clearTokens();
        throw ApiException('Не удалось обновить токен');
      }
    } catch (e) {
      await clearTokens();
      throw ApiException('Ошибка обновления токена: $e');
    }
  }
  
  Future<dynamic> get(String endpoint) async {
    final response = await _handleRequest(
      () => http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders,
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final response = await _handleRequest(
      () => http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    final response = await _handleRequest(
      () => http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> patch(String endpoint, {dynamic body}) async {
    final response = await _handleRequest(
      () => http.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    
    return _handleResponse(response);
  }
  
  Future<dynamic> delete(String endpoint) async {
    final response = await _handleRequest(
      () => http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _authHeaders,
      ),
    );
    
    return _handleResponse(response);
  }
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    
    String errorMessage = 'Ошибка ${response.statusCode}';
    
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map) {
        errorMessage = errorData['detail'] ?? 
                      errorData['error'] ?? 
                      errorData.values.first.toString();
      }
    } catch (_) {
      errorMessage = response.body.isNotEmpty 
        ? response.body 
        : 'Ошибка ${response.statusCode}';
    }
    
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }
}