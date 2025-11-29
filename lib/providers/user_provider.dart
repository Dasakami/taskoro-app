import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/character_class_model.dart';
import '../models/user_model.dart';
import '../screens/main/daily_mission.dart';
import '../screens/main/daily_motivation.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  UserModel? _user;
  DailyMission? _dailyMission;
  DailyMotivation? _dailyMotivation;
  List<CharacterClassModel> _characterClasses = [];
  
  bool _isLoading = false;
  bool _isLoadingClasses = false;
  String? _error;
  
  // Getters
  UserModel? get user => _user;
  DailyMission? get dailyMission => _dailyMission;
  DailyMotivation? get dailyMotivation => _dailyMotivation;
  List<CharacterClassModel> get characterClasses => _characterClasses;
  
  bool get isAuthenticated => _api.isAuthenticated && _user != null;
  bool get isLoading => _isLoading;
  bool get isLoadingClasses => _isLoadingClasses;
  String? get error => _error;
  String? get accessToken => _api._accessToken;
  String get baseUrl => 'http://10.58.136.53:8000/api';
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> init() async {
    await _api.init();
    if (_api.isAuthenticated) {
      await loadFromStorage();
    }
  }
  
  Future<void> loadFromStorage() async {
    if (!_api.isAuthenticated) return;
    
    try {
      await Future.wait([
        fetchUserData(),
        fetchMainData(),
      ]);
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
      await logout();
    }
  }
  
  Future<void> login(String username, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await http.post(
        Uri.parse('${_api._baseUrl}/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _api.setTokens(data['access'], data['refresh']);
        
        await Future.wait([
          fetchUserData(),
          fetchMainData(),
        ]);
        
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Ошибка авторизации');
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> register(
    String username,
    String email,
    String password,
    int classId,
  ) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await http.post(
        Uri.parse('${_api._baseUrl}/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          're_password': password,
          'class_id': classId,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _api.setTokens(data['access'], data['refresh']);
        
        await Future.wait([
          fetchUserData(),
          fetchMainData(),
          fetchCharacterClasses(),
        ]);
        
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData.toString());
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    _user = null;
    _dailyMission = null;
    _dailyMotivation = null;
    _characterClasses = [];
    await _api.clearTokens();
    notifyListeners();
  }
  
  Future<void> fetchUserData() async {
    try {
      final data = await _api.get('/users/me/');
      _user = UserModel.fromJson(data);
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки профиля: $e');
      if (e.toString().contains('401') || e.toString().contains('Refresh token')) {
        await logout();
      }
      rethrow;
    }
  }
  
  Future<void> fetchMainData() async {
    try {
      final data = await _api.get('/main/');
      
      if (data['daily_mission'] != null) {
        _dailyMission = DailyMission.fromJson(data['daily_mission']);
      }
      
      if (data['daily_motivation'] != null) {
        _dailyMotivation = DailyMotivation.fromJson(data['daily_motivation']);
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки главной: $e');
    }
  }
  
  Future<void> fetchCharacterClasses() async {
    _isLoadingClasses = true;
    notifyListeners();
    
    try {
      final data = await _api.get('/users/character-classes/');
      _characterClasses = (data['classes'] as List)
          .map((e) => CharacterClassModel.fromJson(e))
          .toList();
      _error = null;
    } catch (e) {
      _setError('Ошибка загрузки классов: $e');
    } finally {
      _isLoadingClasses = false;
      notifyListeners();
    }
  }
  
  Future<void> updateProfile({
    required String username,
    required String bio,
    String? avatarFilePath,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      http.Response response;
      
      if (avatarFilePath != null) {
        var request = http.MultipartRequest(
          'PATCH',
          Uri.parse('https://daskoro.site/api/users/me/edit/'),
        );
        
        request.headers['Authorization'] = 'Bearer ${_api._accessToken}';
        request.fields['username'] = username;
        request.fields['bio'] = bio;
        
        final mimeType = lookupMimeType(avatarFilePath) ?? 'application/octet-stream';
        final mimeParts = mimeType.split('/');
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFilePath,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
        
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.patch(
          Uri.parse('https://daskoro.site/api/users/me/edit/'),
          headers: {
            'Authorization': 'Bearer ${_api._accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'username': username, 'bio': bio}),
        );
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data);
        _error = null;
        notifyListeners();
      } else {
        throw Exception('Ошибка обновления профиля');
      }
    } catch (e) {
      _setError('Ошибка обновления профиля: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  void updateExperience(int amount) {
    if (_user == null) return;
    
    int newExperience = _user!.experience + amount;
    int newLevel = _user!.level;
    int experienceNeeded = _user!.experienceNeeded;
    
    while (newExperience >= experienceNeeded) {
      newExperience -= experienceNeeded;
      newLevel++;
      experienceNeeded = (experienceNeeded * 1.5).round();
    }
    
    _user = _user!.copyWith(
      experience: newExperience,
      level: newLevel,
      experienceNeeded: experienceNeeded,
    );
    
    notifyListeners();
  }
  
  void updateCurrency({int coins = 0, int gems = 0}) {
    if (_user == null) return;
    
    _user = _user!.copyWith(
      coins: _user!.coins + coins,
      gems: _user!.gems + gems,
    );
    
    notifyListeners();
  }
  
  Future<void> refreshMainData() async {
    await Future.wait([
      fetchUserData(),
      fetchMainData(),
    ]);
  }
  
  // Helper methods для других провайдеров
  Future<http.Response> authGet(Uri url) async {
    try {
      final response = await http.get(url, headers: _authHeaders());
      
      if (response.statusCode == 401) {
        await _api._refreshAccessToken();
        return await http.get(url, headers: _authHeaders());
      }
      
      return response;
    } catch (e) {
      throw Exception('Ошибка запроса: $e');
    }
  }
  
  Future<http.Response> authPost(Uri url, {Map<String, String>? headers, Object? body}) async {
    var mergedHeaders = _authHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    
    try {
      var response = await http.post(url, headers: mergedHeaders, body: body);
      
      if (response.statusCode == 401) {
        await _api._refreshAccessToken();
        response = await http.post(url, headers: mergedHeaders, body: body);
      }
      
      return response;
    } catch (e) {
      throw Exception('Ошибка запроса: $e');
    }
  }
  
  Future<http.Response> authPatch(Uri url, {Map<String, String>? headers, Object? body}) async {
    var mergedHeaders = _authHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    
    try {
      var response = await http.patch(url, headers: mergedHeaders, body: body);
      
      if (response.statusCode == 401) {
        await _api._refreshAccessToken();
        response = await http.patch(url, headers: mergedHeaders, body: body);
      }
      
      return response;
    } catch (e) {
      throw Exception('Ошибка запроса: $e');
    }
  }
  
  Future<http.Response> authPut(Uri url, {Map<String, String>? headers, Object? body}) async {
    var mergedHeaders = _authHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    
    try {
      var response = await http.put(url, headers: mergedHeaders, body: body);
      
      if (response.statusCode == 401) {
        await _api._refreshAccessToken();
        response = await http.put(url, headers: mergedHeaders, body: body);
      }
      
      return response;
    } catch (e) {
      throw Exception('Ошибка запроса: $e');
    }
  }
  
  Future<http.Response> authDelete(Uri url, {Map<String, String>? headers}) async {
    var mergedHeaders = _authHeaders();
    if (headers != null) mergedHeaders.addAll(headers);
    
    try {
      var response = await http.delete(url, headers: mergedHeaders);
      
      if (response.statusCode == 401) {
        await _api._refreshAccessToken();
        response = await http.delete(url, headers: mergedHeaders);
      }
      
      return response;
    } catch (e) {
      throw Exception('Ошибка запроса: $e');
    }
  }
  
  Map<String, String> _authHeaders() {
    return {
      'Authorization': 'Bearer ${_api._accessToken}',
      'Content-Type': 'application/json',
    };
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
  
  void initDemoUser() {
    _user = UserModel(
      id: '1',
      username: 'DemoUser',
      level: 5,
      experience: 75,
      experienceNeeded: 150,
      coins: 240,
      gems: 15,
      streak: 3,
    );
    notifyListeners();
  }
}