import 'package:flutter/material.dart';
import '../models/base_task.dart';
import '../services/api_service.dart';

class BaseHabitProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<BaseTaskModel> _habits = [];
  bool _isLoading = false;
  String? _error;
  
  List<BaseTaskModel> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get loading => _isLoading;
  
  Future<void> fetchHabits() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/habits/');
      
      if (data is List) {
        _habits = data.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['habits'] as List? ?? [];
        _habits = list.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки привычек: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> logHabit(int habitId) async {
    try {
      await _api.post('/habits/$habitId/log/');
      await fetchHabits();
      return true;
    } catch (e) {
      _setError('Ошибка логирования привычки: $e');
      return false;
    }
  }
  
  /// Alias для logHabit (для совместимости)
  Future<bool> complete(dynamic habitIdOrModel) {
    if (habitIdOrModel is int) {
      return logHabit(habitIdOrModel);
    } else if (habitIdOrModel is BaseTaskModel) {
      return logHabit(habitIdOrModel.id);
    }
    throw ArgumentError('Invalid argument type');
  }
  
  /// Fetch alias
  Future<void> fetch() => fetchHabits();
  
  void clearData() {
    _habits.clear();
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
