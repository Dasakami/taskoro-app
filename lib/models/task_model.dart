import 'package:flutter/material.dart';

enum TaskType {
  oneTime,
  habit,
  daily,
}

enum TaskDifficulty {
  easy,
  medium,
  hard,
  epic,
}

enum TaskStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}

class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final TaskType type;
  final TaskDifficulty difficulty;
  final TaskStatus status;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? categoryId;
  final int coins;
  final int? estimatedMinutes;
  final String? frequency;

  // For habits
  final int streak;
  final DateTime? lastCompleted;

  // For daily goals
  final DateTime? targetDate;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.type,
    required this.difficulty,
    this.status = TaskStatus.notStarted,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.coins = 0,
    this.estimatedMinutes,
    this.frequency,
    this.streak = 0,
    this.lastCompleted,
    this.targetDate,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isHabit => type == TaskType.habit;
  bool get isDaily => type == TaskType.daily;
  bool get isOneTime => type == TaskType.oneTime;

  // For backward compatibility
  int get experienceReward => _getExperienceReward();
  int get coinsReward => coins;

  int _getExperienceReward() {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 10;
      case TaskDifficulty.medium:
        return 20;
      case TaskDifficulty.hard:
        return 35;
      case TaskDifficulty.epic:
        return 50;
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return const Color(0xFF33FF99);
      case TaskDifficulty.medium:
        return const Color(0xFFFFCC33);
      case TaskDifficulty.hard:
        return const Color(0xFFFF3366);
      case TaskDifficulty.epic:
        return const Color(0xFF6633FF);
    }
  }

  String get difficultyName {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 'Легкая';
      case TaskDifficulty.medium:
        return 'Средняя';
      case TaskDifficulty.hard:
        return 'Сложная';
      case TaskDifficulty.epic:
        return 'Эпическая';
    }
  }

  String get statusName {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Не начата';
      case TaskStatus.inProgress:
        return 'В процессе';
      case TaskStatus.completed:
        return 'Завершена';
      case TaskStatus.paused:
        return 'Приостановлена';
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.paused:
        return Colors.orange;
    }
  }

  // JSON serialization
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      type: _taskTypeFromString(json['task_type'] ?? 'one_time'),
      difficulty: _taskDifficultyFromString(json['difficulty'] ?? 'easy'),
      status: _taskStatusFromString(json['status'] ?? 'not_started'),
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      categoryId: json['category'],
      coins: json['coins'] ?? 0,
      estimatedMinutes: json['estimated_minutes'],
      frequency: json['frequency'],
      streak: json['streak'] ?? 0,
      lastCompleted: json['last_completed'] != null ? DateTime.tryParse(json['last_completed']) : null,
      targetDate: json['target_date'] != null ? DateTime.tryParse(json['target_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'task_type': _taskTypeToString(type),
      'difficulty': _difficultyToString(difficulty),
      'status': _statusToString(status),
      'deadline': deadline?.toIso8601String(),
      'category': categoryId,
      'coins': coins,
      'estimated_minutes': estimatedMinutes,
      'frequency': frequency,
      'streak': streak,
      'last_completed': lastCompleted?.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    TaskType? type,
    TaskDifficulty? difficulty,
    TaskStatus? status,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? categoryId,
    int? coins,
    int? estimatedMinutes,
    String? frequency,
    int? streak,
    DateTime? lastCompleted,
    DateTime? targetDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      coins: coins ?? this.coins,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      frequency: frequency ?? this.frequency,
      streak: streak ?? this.streak,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  // Helper methods for enum conversion
  static TaskType _taskTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'one_time':
      case 'onetime':
        return TaskType.oneTime;
      case 'habit':
        return TaskType.habit;
      case 'daily':
        return TaskType.daily;
      default:
        return TaskType.oneTime;
    }
  }

  static String _taskTypeToString(TaskType type) {
    switch (type) {
      case TaskType.oneTime:
        return 'one_time';
      case TaskType.habit:
        return 'habit';
      case TaskType.daily:
        return 'daily';
    }
  }

  static TaskDifficulty _taskDifficultyFromString(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return TaskDifficulty.easy;
      case 'medium':
        return TaskDifficulty.medium;
      case 'hard':
        return TaskDifficulty.hard;
      case 'epic':
        return TaskDifficulty.epic;
      default:
        return TaskDifficulty.easy;
    }
  }

  static String _difficultyToString(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 'easy';
      case TaskDifficulty.medium:
        return 'medium';
      case TaskDifficulty.hard:
        return 'hard';
      case TaskDifficulty.epic:
        return 'epic';
    }
  }

  static TaskStatus _taskStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'not_started':
        return TaskStatus.notStarted;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'paused':
        return TaskStatus.paused;
      default:
        return TaskStatus.notStarted;
    }
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'not_started';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.paused:
        return 'paused';
    }
  }
}

// Existing classes for backward compatibility
class DailyMission {
  final String id;
  final String title;
  final String description;
  final int experienceReward;
  final int coinsReward;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.experienceReward,
    required this.coinsReward,
  });

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      experienceReward: json['experience_reward'] ?? 0,
      coinsReward: json['coins_reward'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'experience_reward': experienceReward,
      'coins_reward': coinsReward,
    };
  }
}

class TaskCategory {
  final int id;
  final String name;
  final String? description;
  final Color? color;

  TaskCategory({
    required this.id,
    required this.name,
    this.description,
    this.color,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'] != null ? Color(int.parse(json['color'].substring(1), radix: 16) + 0xFF000000) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color != null ? '#${color!.value.toRadixString(16).substring(2)}' : null,
    };
  }
}

