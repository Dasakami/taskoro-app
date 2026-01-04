import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/api_service.dart';

class AchievementProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;
  
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isAcquired).toList();
  List<Achievement> get lockedAchievements => _achievements.where((a) => !a.isAcquired).toList();
  int get totalCount => _achievements.length;
  int get acquiredCount => unlockedAchievements.length;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchAchievements() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/history/achievements/');
      
      if (data is List) {
        _achievements = data.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['achievements'] as List? ?? [];
        _achievements = list.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки достижений: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void clearData() {
    _achievements.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
