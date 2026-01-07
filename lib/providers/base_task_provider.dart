import 'package:flutter/material.dart';
import '../models/base_task.dart';
import '../services/api_service.dart';

class BaseTaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<BaseTaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  
  List<BaseTaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get loading => _isLoading;
  
  /// Фильтрация по типу
  List<BaseTaskModel> get oneTimers => _tasks.where((t) => t.type == BaseTaskType.oneTime).toList();
  List<BaseTaskModel> get dailies => _tasks.where((t) => t.type == BaseTaskType.daily).toList();
  List<BaseTaskModel> get habits => _tasks.where((t) => t.type == BaseTaskType.habit).toList();
  
  /// Фильтрация выполненных и невыполненных
  List<BaseTaskModel> get completedTasks => _tasks.where((t) => t.completed).toList();
  List<BaseTaskModel> get incompleteTasks => _tasks.where((t) => !t.completed).toList();
  
  Future<void> fetchBaseTasks() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/tasks/base-tasks/');
      
      if (data is List) {
        _tasks = data.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
        // Сортируем: невыполненные сначала
        _tasks.sort((a, b) {
          if (a.completed == b.completed) return 0;
          return a.completed ? 1 : -1;
        });
      } else if (data is Map) {
        final list = data['tasks'] as List? ?? [];
        _tasks = list.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
        _tasks.sort((a, b) {
          if (a.completed == b.completed) return 0;
          return a.completed ? 1 : -1;
        });
      }
    } catch (e) {
      _setError('Ошибка загрузки базовых задач: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> completeBaseTask(int taskId) async {
    try {
      final response = await _api.post('/tasks/base-tasks/$taskId/complete/');
      
      // Обновляем локальный статус задачи
      if (response is Map && response['completed'] == true) {
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(completed: true);
          // Пересортируем
          _tasks.sort((a, b) {
            if (a.completed == b.completed) return 0;
            return a.completed ? 1 : -1;
          });
          notifyListeners();
        }
      }
      
      return true;
    } catch (e) {
      _setError('Ошибка выполнения задачи: $e');
      return false;
    }
  }
  
  Future<bool> complete(dynamic taskIdOrModel) {
    if (taskIdOrModel is int) {
      return completeBaseTask(taskIdOrModel);
    } else if (taskIdOrModel is BaseTaskModel) {
      return completeBaseTask(taskIdOrModel.id);
    }
    throw ArgumentError('Invalid argument type');
  }
  
  void clearData() {
    _tasks.clear();
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

