import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../models/character_class_model.dart';
import '../models/user_model.dart';
import '../screens/main/daily_mission.dart';
import '../screens/main/daily_motivation.dart';
import '../services/api_service.dart';

/// Провайдер для управления пользователем и авторизацией
class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Данные пользователя
  UserModel? _user;
  DailyMission? _dailyMission;
  DailyMotivation? _dailyMotivation;
  List<CharacterClassModel> _characterClasses = [];
  
  // Состояние
  bool _isLoading = false;
  bool _isLoadingClasses = false;
  String? _error;
  
  // ===================== GETTERS =====================
  
  UserModel? get user => _user;
  DailyMission? get dailyMission => _dailyMission;
  DailyMotivation? get dailyMotivation => _dailyMotivation;
  List<CharacterClassModel> get characterClasses => _characterClasses;
  
  bool get isAuthenticated => _api.isAuthenticated && _user != null;
  bool get isLoading => _isLoading;
  bool get isLoadingClasses => _isLoadingClasses;
  String? get error => _error;
  String? get accessToken => _api.accessToken;
  
  // ===================== ИНИЦИАЛИЗАЦИЯ =====================
  
  Future<void> init() async {
    await _api.init();
    if (_api.isAuthenticated) {
      await _loadUserData();
    }
  }
  
  // ===================== АВТОРИЗАЦИЯ =====================
  
  Future<void> login(String username, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _api.login(username, password);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userId = data['user_id'] as int?;
        
        await _api.setTokens(
          data['access'],
          data['refresh'],
          userId: userId,
        );
        
        await _loadUserData();
        notifyListeners();
      } else {
        throw ApiException('Неверные учетные данные', statusCode: response.statusCode);
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
      final response = await _api.post('/users/register/', body: {
        'username': username,
        'email': email,
        'password': password,
        're_password': password,
        'class_id': classId,
      }, auth: false);
      
      if (response is Map<String, dynamic>) {
        await _api.setTokens(
          response['access'],
          response['refresh'],
          userId: response['user_id'] as int?,
        );
        
        await _loadUserData();
        notifyListeners();
      } else {
        throw ApiException('Ошибка регистрации');
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
    _error = null;
    await _api.clearTokens();
    notifyListeners();
  }
  
  // ===================== ЗАГРУЗКА ДАННЫХ =====================
  
  Future<void> _loadUserData() async {
    if (!_api.isAuthenticated) {
      _setError('Пользователь не авторизован');
      return;
    }
    
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
  
  /// Обновить данные пользователя со всех экранов
  Future<void> refreshUserData() async {
    if (!_api.isAuthenticated) return;
    await _loadUserData();
  }
  
  /// Alias для refreshUserData (используется в старом коде)
  Future<void> refreshMainData() => refreshUserData();
  
  Future<void> fetchUserData() async {
    try {
      final data = await _api.get('/users/me/');
      _user = UserModel.fromJson(data as Map<String, dynamic>);
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
      final data = await _api.get('/users/me/edit/') as Map<String, dynamic>?;
      if (data != null) {
        if (data['daily_mission'] != null) {
          _dailyMission = DailyMission.fromJson(data['daily_mission']);
        }
        if (data['daily_motivation'] != null) {
          _dailyMotivation = DailyMotivation.fromJson(data['daily_motivation']);
        }
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
      final classList = (data is Map ? data['classes'] as List? : data as List?) ?? [];
      _characterClasses = classList
          .map((e) => CharacterClassModel.fromJson(e as Map<String, dynamic>))
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
    File? avatarFile,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      dynamic response;
      
      if (avatarFile != null) {
        // Multipart request с файлом
        response = await _api.multipartRequest(
          'PATCH',
          '/users/me/edit/',
          fields: {
            'username': username,
            'bio': bio,
          },
          files: {
            'avatar': avatarFile,
          },
        );
      } else {
        // Обычный PATCH запрос
        response = await _api.patch(
          '/users/me/edit/',
          body: {
            'username': username,
            'bio': bio,
          },
        );
      }
      
      if (response is Map<String, dynamic>) {
        _user = UserModel.fromJson(response);
        _error = null;
        notifyListeners();
      } else {
        throw ApiException('Ошибка обновления профиля');
      }
    } catch (e) {
      _setError('Ошибка обновления профиля: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== ОБНОВЛЕНИЕ ДАННЫХ ЛОКАЛЬНО =====================
  
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