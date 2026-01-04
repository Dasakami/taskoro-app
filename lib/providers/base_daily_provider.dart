import 'package:flutter/material.dart';
import '../models/base_task.dart';
import '../services/api_service.dart';

class BaseDailyProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<BaseTaskModel> _dailyTasks = [];
  bool _isLoading = false;
  String? _error;
  
  List<BaseTaskModel> get dailyTasks => _dailyTasks;
  List<BaseTaskModel> get completedTasks => _dailyTasks.where((t) => t.isCompleted).toList();
  List<BaseTaskModel> get incompleteTasks => _dailyTasks.where((t) => !t.isCompleted).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get loading => _isLoading;
  
  /// Alias для совместимости
  List<BaseTaskModel> get dailies => _dailyTasks;
  double get completionPercentage {
    if (_dailyTasks.isEmpty) return 0.0;
    return (completedTasks.length / _dailyTasks.length) * 100;
  }
  
  Future<void> fetchDailyTasks() async {
    if (!_api.isAuthenticated) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/tasks/tasks/?task_type=daily');
      
      if (data is List) {
        _dailyTasks = data.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map) {
        final list = data['tasks'] as List? ?? [];
        _dailyTasks = list.map((e) => BaseTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _setError('Ошибка загрузки ежедневных задач: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> completeDailyTask(int taskId) async {
    try {
      await _api.post('/tasks/tasks/$taskId/complete/');
      await fetchDailyTasks();
      return true;
    } catch (e) {
      _setError('Ошибка выполнения задачи: $e');
      return false;
    }
  }
  
  /// Alias để completeDailyTask (для совместимости)
  Future<bool> complete(dynamic taskIdOrModel) {
    if (taskIdOrModel is int) {
      return completeDailyTask(taskIdOrModel);
    } else if (taskIdOrModel is BaseTaskModel) {
      return completeDailyTask(taskIdOrModel.id);
    }
    throw ArgumentError('Invalid argument type');
  }
  
  /// Fetch alias для fetchDailyTasks
  Future<void> fetch() => fetchDailyTasks();
  
  void clearData() {
    _dailyTasks.clear();
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
