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
  
  /// Getters для совместимости
  List<BaseTaskModel> get oneTimers => _tasks;
  List<BaseTaskModel> get dailies => _tasks;
  List<BaseTaskModel> get habits => _tasks;
  
  Future<void> fetchBaseTasks() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/tasks/base-tasks/');
      
      if (data is List) {
        _tasks = data.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['tasks'] as List? ?? [];
        _tasks = list.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки базовых задач: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> completeBaseTask(int taskId) async {
    try {
      await _api.post('/tasks/base-tasks/$taskId/complete/');
      await fetchBaseTasks();
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
