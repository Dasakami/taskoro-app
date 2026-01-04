import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

/// Провайдер для управления задачами (обычными, ежедневными, привычками)
class TasksProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  // Данные задач
  List<TaskModel> _tasks = [];
  List<TaskCategory> _categories = [];
  
  // Состояние
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // ===================== GETTERS =====================
  
  List<TaskModel> get tasks => _tasks;
  List<TaskCategory> get categories => _categories;
  
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  
  /// Последние 5 задач
  List<TaskModel> get recentTasks {
    final sorted = List<TaskModel>.from(_tasks);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }
  
  /// Выполненные задачи на сегодня
  List<TaskModel> get completedTasksToday {
    final today = DateTime.now();
    return _tasks.where((task) =>
        task.isCompleted &&
        task.updatedAt.year == today.year &&
        task.updatedAt.month == today.month &&
        task.updatedAt.day == today.day
    ).toList();
  }
  
  /// Процент выполненных задач
  double get completedTasksPercentage {
    if (_tasks.isEmpty) return 0.0;
    final completed = _tasks.where((t) => t.isCompleted).length;
    return (completed / _tasks.length) * 100;
  }
  
  /// Задачи по типу
  List<TaskModel> getTasksByType(TaskType type) {
    return _tasks.where((task) => task.type == type).toList();
  }
  
  /// Активные задачи (не выполненные)
  List<TaskModel> get activeTasks {
    return _tasks.where((t) => !t.isCompleted).toList();
  }
  
  // ===================== ЗАГРУЗКА ДАННЫХ =====================
  
  /// Загрузить все задачи
  Future<void> fetchTasks() async {
    if (!_api.isAuthenticated) {
      _setError('Пользователь не авторизован');
      return;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.get('/tasks/tasks/');
      
      if (data is List) {
        _tasks = data
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['tasks'] as List? ?? [];
        _tasks = list
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _setError('Ошибка загрузки задач: $e');
      debugPrint('Ошибка fetchTasks: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Загрузить категории задач
  Future<void> fetchCategories() async {
    if (!_api.isAuthenticated) return;
    
    try {
      final data = await _api.get('/tasks/tasks/categories/');
      
      if (data is List) {
        _categories = data
            .map((e) => TaskCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final list = data['categories'] as List? ?? [];
        _categories = list
            .map((e) => TaskCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки категорий: $e');
    }
  }
  
  /// Загрузить все данные (задачи и категории)
  Future<void> fetchAll() async {
    await Future.wait([
      fetchTasks(),
      fetchCategories(),
    ]);
  }
  
  // ===================== СОЗДАНИЕ И РЕДАКТИРОВАНИЕ =====================
  
  /// Создать новую задачу
  Future<TaskModel?> createTask(TaskModel task) async {
    if (!_api.isAuthenticated) {
      _setError('Пользователь не авторизован');
      return null;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final taskData = task.toJson();
      taskData.remove('id');
      
      final data = await _api.post('/tasks/tasks/', body: taskData);
      
      if (data is Map<String, dynamic>) {
        final createdTask = TaskModel.fromJson(data);
        _tasks.add(createdTask);
        notifyListeners();
        return createdTask;
      } else {
        throw ApiException('Ошибка создания задачи');
      }
    } catch (e) {
      _setError('Ошибка создания задачи: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Обновить существующую задачу
  Future<TaskModel?> updateTask(TaskModel task) async {
    if (!_api.isAuthenticated || task.id == null) {
      _setError('Невозможно обновить задачу');
      return null;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final data = await _api.put(
        '/tasks/${task.id}/',
        body: task.toJson(),
      );
      
      if (data is Map<String, dynamic>) {
        final updatedTask = TaskModel.fromJson(data);
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return updatedTask;
      } else {
        throw ApiException('Ошибка обновления задачи');
      }
    } catch (e) {
      _setError('Ошибка обновления задачи: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== УДАЛЕНИЕ =====================
  
  /// Удалить задачу
  Future<bool> deleteTask(int taskId) async {
    if (!_api.isAuthenticated) {
      _setError('Пользователь не авторизован');
      return false;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      await _api.delete('/tasks/tasks/$taskId/');
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка удаления задачи: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===================== ВЫПОЛНЕНИЕ ЗАДАЧ =====================
  
  /// Отметить задачу как выполненную
  Future<TaskModel?> completeTask(int taskId) async {
    if (!_api.isAuthenticated) {
      _setError('Пользователь не авторизован');
      return null;
    }
    
    try {
      final data = await _api.post('/tasks/tasks/$taskId/complete/');
      
      if (data is Map<String, dynamic>) {
        final updatedTask = TaskModel.fromJson(data);
        final index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return updatedTask;
      } else {
        throw ApiException('Ошибка выполнения задачи');
      }
    } catch (e) {
      _setError('Ошибка выполнения задачи: $e');
      return null;
    }
  }
  
  /// Alias для completeTask
  Future<TaskModel?> completeTaskById(int taskId) => completeTask(taskId);
  
  /// Переключить статус задачи
  Future<TaskModel?> toggleTaskStatus(TaskModel task) async {
    final newStatus = task.isCompleted ? TaskStatus.notStarted : TaskStatus.completed;
    return await updateTask(task.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    ));
  }
  
  // ===================== УТИЛИТЫ =====================
  
  /// Очистить все данные
  void clearData() {
    _tasks.clear();
    _categories.clear();
    _error = null;
    _isLoading = false;
    _isInitialized = false;
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
