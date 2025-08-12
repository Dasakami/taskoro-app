import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import 'user_provider.dart';

class TasksProvider extends ChangeNotifier {
  final UserProvider userProvider;
  final String baseUrl;

  TasksProvider({
    required this.userProvider,
    this.baseUrl = 'https://taskoro.onrender.com',
  });

  List<TaskModel> _tasks = [];
  List<TaskCategory> _categories = [];
  bool _isLoading = false;
  String? _error;


  // Getters
  List<TaskModel> get tasks => _tasks;
  List<TaskCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;


  // Отфильтрованные задачи
  List<TaskModel> get recentTasks {
    final sortedTasks = List<TaskModel>.from(_tasks);
    sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedTasks.take(5).toList();
  }

  List<TaskModel> get completedTasksToday {
    final today = DateTime.now();
    return _tasks.where((task) =>
    task.isCompleted &&
        task.updatedAt.year == today.year &&
        task.updatedAt.month == today.month &&
        task.updatedAt.day == today.day
    ).toList();
  }

  double get completedTasksPercentage {
    if (_tasks.isEmpty) return 0;
    final completed = _tasks.where((t) => t.isCompleted).length;
    return completed / _tasks.length;
  }

  List<TaskModel> getTasksByType(TaskType type) {
    return _tasks.where((task) => task.type == type).toList();
  }

  // Вспомогательные методы
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (userProvider.accessToken != null) {
      headers['Authorization'] = 'Bearer ${userProvider.accessToken}';
    }

    return headers;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // API Methods
  Future<void> fetchTasks() async {
    if (userProvider.accessToken == null) {
      _setError('Пользователь не авторизован');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/tasks/tasks/');
      final response = await userProvider.authGet(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _tasks = data.map((json) => TaskModel.fromJson(json)).toList();
        _setError(null);
      } else {
        _setError('Ошибка загрузки задач: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    if (userProvider.accessToken == null) return;

    try {
      final url = Uri.parse('$baseUrl/api/tasks/categories/');
      final response = await userProvider.authGet(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _categories = data.map((json) => TaskCategory.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки категорий: $e');
    }
  }

  Future<TaskModel?> createTask(TaskModel task) async {
    if (userProvider.accessToken == null) {
      _setError('Пользователь не авторизован');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/tasks/tasks/');
      final taskData = task.toJson();
      taskData.remove('id'); // Удаляем id для создания

      final response = await userProvider.authPost(
        Uri.parse('$baseUrl/api/tasks/tasks/'),
        body: jsonEncode(taskData),
      );


      if (response.statusCode == 201) {
        final createdTask = TaskModel.fromJson(jsonDecode(response.body));
        _tasks.add(createdTask);
        notifyListeners();
        return createdTask;
      } else {
        _setError('Ошибка создания задачи: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel?> updateTask(TaskModel task) async {
    if (userProvider.accessToken == null || task.id == null) {
      _setError('Невозможно обновить задачу');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/tasks/tasks/${task.id}/');
      final response = await userProvider.authPut(
        url,
        body: jsonEncode(task.toJson()),
      );


      if (response.statusCode == 200) {
        final updatedTask = TaskModel.fromJson(jsonDecode(response.body));
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        return updatedTask;
      } else {
        _setError('Ошибка обновления задачи: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTask(int taskId) async {
    if (userProvider.accessToken == null) {
      _setError('Пользователь не авторизован');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/tasks/tasks/$taskId/');
      final response = await userProvider.authDelete(url);


      if (response.statusCode == 204) {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
        return true;
      } else {
        _setError('Ошибка удаления задачи: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Новый метод для выполнения задачи по её id
  Future<TaskModel?> completeTaskById(int taskId) async {
    if (userProvider.accessToken == null) {
      _setError('Пользователь не авторизован');
      debugPrint("completeTaskById: accessToken отсутствует");
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final url = Uri.parse('$baseUrl/api/tasks/tasks/$taskId/complete/');
      debugPrint("Вызов API для выполнения задачи: $url");

      final response = await userProvider.authPost(url);
      debugPrint("Статус ответа API: ${response.statusCode}");

      if (response.statusCode == 200) {
        final updatedTask = TaskModel.fromJson(jsonDecode(response.body));
        final index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        } else {
          debugPrint("Задача с id $taskId не найдена в локальном списке");
        }
        return updatedTask;
      } else {
        _setError('Ошибка выполнения задачи: ${response.statusCode}');
        debugPrint("Тело ответа: ${response.body}");
        return null;
      }
    } catch (e) {
      _setError('Ошибка сети: $e');
      debugPrint("Исключение при выполнении задачи: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskModel?> toggleTaskStatus(TaskModel task) async {
    final newStatus =
    task.isCompleted ? TaskStatus.notStarted : TaskStatus.completed;
    return await updateTask(task.copyWith(
      status: newStatus,
      lastCompleted: newStatus == TaskStatus.completed ? DateTime.now() : null,
    ));
  }


  // Demo данные для разработки
  void initDemoData() {
    _tasks = [
      TaskModel(
        id: 1,
        title: 'Первая задача',
        description: 'Описание первой задачи',
        type: TaskType.oneTime,
        difficulty: TaskDifficulty.easy,
        status: TaskStatus.notStarted,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        coins: 10,
      ),
      TaskModel(
        id: 2,
        title: 'Привычка: читать книги',
        description: 'Читать по 30 минут каждый день',
        type: TaskType.habit,
        difficulty: TaskDifficulty.medium,
        status: TaskStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        coins: 15,
        streak: 2,
        lastCompleted: DateTime.now(),
      ),
      TaskModel(
        id: 3,
        title: 'Цель: выучить 10 новых слов',
        description: 'Изучить 10 новых английских слов',
        type: TaskType.daily,
        difficulty: TaskDifficulty.hard,
        status: TaskStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coins: 25,
        targetDate: DateTime.now(),
      ),
    ];



    notifyListeners();
  }

  // Очистка всех данных
  void clearData() {
    _tasks.clear();
    _categories.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
