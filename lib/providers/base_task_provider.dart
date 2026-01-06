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
  
  /// Getters для фильтрации по типу
  List<BaseTaskModel> get oneTimers => _tasks.where((t) => t.type == BaseTaskType.oneTime).toList();
  List<BaseTaskModel> get dailies => _tasks.where((t) => t.type == BaseTaskType.daily).toList();
  List<BaseTaskModel> get habits => _tasks.where((t) => t.type == BaseTaskType.habit).toList();
  
  Future<void> fetchBaseTasks() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/tasks/base-tasks/');
      
      if (data is List) {
        _tasks = data.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['tasks'] as List? ?? data['base_tasks'] as List? ?? [];
        _tasks = list.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      
      // Сортируем задачи: невыполненные сначала, затем по типу и сложности
      _tasks.sort((a, b) {
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        if (a.type != b.type) return a.type.index.compareTo(b.type.index);
        return a.title.compareTo(b.title);
      });
      
    } catch (e) {
      _setError('Ошибка загрузки базовых задач: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> completeBaseTask(int taskId) async {
    try {
      final response = await _api.post('/tasks/base-tasks/$taskId/complete/');
      
      // Обновляем локальное состояние задачи
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(completed: true);
        
        // Пересортировываем список
        _tasks.sort((a, b) {
          if (a.completed != b.completed) return a.completed ? 1 : -1;
          if (a.type != b.type) return a.type.index.compareTo(b.type.index);
          return a.title.compareTo(b.title);
        });
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Ошибка выполнения задачи: $e');
      return false;
    }
  }
  
  /// Alias для completeBaseTask
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