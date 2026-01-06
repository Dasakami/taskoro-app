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
      final data = await _api.get('/tasks/base-tasks/?task_type=habit');
      
      if (data is List) {
        _habits = data.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['habits'] as List? ?? data['tasks'] as List? ?? [];
        _habits = list.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      
      // Сортируем: невыполненные сначала
      _habits.sort((a, b) {
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        return a.title.compareTo(b.title);
      });
      
    } catch (e) {
      _setError('Ошибка загрузки привычек: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> logHabit(int habitId) async {
    try {
      await _api.post('/tasks/base-tasks/$habitId/complete/');
      
      // Обновляем локальное состояние
      final index = _habits.indexWhere((t) => t.id == habitId);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(completed: true);
        
        // Пересортировываем
        _habits.sort((a, b) {
          if (a.completed != b.completed) return a.completed ? 1 : -1;
          return a.title.compareTo(b.title);
        });
        
        notifyListeners();
      }
      
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