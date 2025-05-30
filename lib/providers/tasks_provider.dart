import 'package:flutter/material.dart';
import 'package:taskoro/models/task_model.dart';

class TasksProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];
  DailyMission? _dailyMission;
  Motivation? _dailyMotivation;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  DailyMission? get dailyMission => _dailyMission;
  Motivation? get dailyMotivation => _dailyMotivation;

  List<TaskModel> get recentTasks =>
      _tasks.take(5).toList();

  List<TaskModel> get completedTasksToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) =>
    task.isCompleted &&
        task.createdAt.isAfter(today)
    ).toList();
  }

  int get completedTasksPercentage {
    if (_tasks.isEmpty) return 0;

    final completed = completedTasksToday.length;
    final total = _tasks.where((task) =>
    task.createdAt.day == DateTime.now().day
    ).length;

    if (total == 0) return 0;
    return (completed / total * 100).round();
  }

  void initDemoData() {
    // Add some demo tasks
    _tasks.addAll([
      TaskModel(
        id: '1',
        title: 'Прочитать 20 страниц книги',
        description: 'Продолжить чтение "Атомные привычки"',
        createdAt: DateTime.now(),
        experienceReward: 15,
        coinsReward: 7,
      ),
      TaskModel(
        id: '2',
        title: 'Медитация 10 минут',
        createdAt: DateTime.now(),
        isCompleted: true,
        experienceReward: 10,
        coinsReward: 5,
      ),
      TaskModel(
        id: '3',
        title: 'Тренировка 30 минут',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        experienceReward: 20,
        coinsReward: 10,
      ),
    ]);

    // Set daily mission
    _dailyMission = DailyMission(
      id: '1',
      title: 'Выполни 3 задачи сегодня',
      description: 'Завершите любые 3 задачи из вашего списка до конца дня',
      experienceReward: 30,
      coinsReward: 15,
    );

    // Set daily motivation
    _dailyMotivation = Motivation(
      text: 'Не ждите вдохновения. Оно приходит во время работы.',
      author: 'Анри Матисс',
    );

    notifyListeners();
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskComplete(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index >= 0) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}