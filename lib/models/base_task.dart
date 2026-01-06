enum BaseTaskType { oneTime, habit, daily }

class BaseTaskModel {
  final int id;
  final String title;
  final String description;
  final int xpReward;
  final BaseTaskType type;
  final bool completed;

  BaseTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.type,
    this.completed = false,
  });

  factory BaseTaskModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['task_type'] as String?)
        ?? (json['type'] as String?)
        ?? 'one_time';

    BaseTaskType parseType(String s) {
      switch (s) {
        case 'habit':
          return BaseTaskType.habit;
        case 'daily':
          return BaseTaskType.daily;
        default:
          return BaseTaskType.oneTime;
      }
    }

    return BaseTaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      xpReward: json['xp_reward'] as int? ?? 0,
      type: parseType(rawType),
      completed: json['completed'] as bool? ?? false,
    );
  }
  
  /// Alias для совместимости
  bool get isCompleted => completed;
  
  /// Метод для создания копии с обновленными полями
  BaseTaskModel copyWith({
    int? id,
    String? title,
    String? description,
    int? xpReward,
    BaseTaskType? type,
    bool? completed,
  }) {
    return BaseTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
  }
}