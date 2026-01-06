import 'dart:convert';
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
      // Логин возвращает токены и user_id
      final data = await _api.login(username, password);
      
      await _api.setTokens(
        data['access'],
        data['refresh'],
        userId: data['user_id'] as int?,
      );
      
      // Загрузить данные пользователя
      await _loadUserData();
      notifyListeners();
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
      // Загружаем данные пользователя и главной страницы параллельно
      await Future.wait([
        fetchUserData(),
        fetchMainData(),
      ]);
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
      // Не выходим автоматически, если ошибка не связана с авторизацией
      if (e.toString().contains('401') || e.toString().contains('Refresh token')) {
        await logout();
      }
    }
  }
  
  /// Обновить данные пользователя
  Future<void> refreshUserData() async {
    if (!_api.isAuthenticated) return;
    await _loadUserData();
  }
  
  /// Обновить только данные главной страницы
  Future<void> refreshMainData() async {
    if (!_api.isAuthenticated) return;
    await fetchMainData();
  }
  
  /// Получить профиль пользователя из /users/me/
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
  
  /// Получить данные главной страницы из /main/
  Future<void> fetchMainData() async {
    try {
      final data = await _api.get('/main/') as Map<String, dynamic>?;
      if (data != null) {
        // Обновляем профиль если есть
        if (data['profile'] != null) {
          final profileData = data['profile'] as Map<String, dynamic>;
          if (_user != null) {
            _user = _user!.copyWith(
              level: profileData['level'] as int?,
              experience: profileData['experience'] as int?,
              experienceNeeded: profileData['experience_needed'] as int?,
              coins: profileData['coins'] as int?,
              gems: profileData['gems'] as int?,
              streak: profileData['streak'] as int?,
            );
          }
        }
        
        // Дневная миссия
        if (data['daily_mission'] != null) {
          _dailyMission = DailyMission.fromJson(data['daily_mission']);
        }
        
        // Мотивация
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
  
  /// Получить список классов персонажей
  Future<void> fetchCharacterClasses() async {
    _isLoadingClasses = true;
    notifyListeners();
    
    try {
      final data = await _api.get('/users/character-classes/', auth: false);
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
  
  /// Обновить профиль (только для страницы редактирования)
  Future<void> updateProfile({
    required String username,
    required String bio,
    String? avatarFilePath,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // PATCH запрос к /users/me/edit/
      final response = await _api.patch(
        '/users/me/edit/',
        body: {
          'username': username,
          'bio': bio,
          if (avatarUrl != null) 'avatar': avatarUrl,
        },
      );
      
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