import 'package:intl/intl.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isCompleted;
  final int experienceReward;
  final int coinsReward;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
    this.experienceReward = 10,
    this.coinsReward = 5,
  });

  String get formattedCreatedDate =>
      DateFormat('dd.MM.yyyy').format(createdAt);

  String? get formattedDeadline =>
      deadline != null ? DateFormat('dd.MM.yyyy').format(deadline!) : null;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isCompleted,
    int? experienceReward,
    int? coinsReward,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      experienceReward: experienceReward ?? this.experienceReward,
      coinsReward: coinsReward ?? this.coinsReward,
    );
  }
}

class DailyMission {
  final String id;
  final String title;
  final String description;
  final int experienceReward;
  final int coinsReward;
  final bool isCompleted;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    this.experienceReward = 20,
    this.coinsReward = 10,
    this.isCompleted = false,
  });
}

class Motivation {
  final String text;
  final String? author;

  Motivation({
    required this.text,
    this.author,
  });
}