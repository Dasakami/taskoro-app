class Tournament {
  final int id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final int experienceReward;
  final int coinsReward;
  final int gemsReward;
  final int minTasksCompleted;

  Tournament({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.experienceReward,
    required this.coinsReward,
    required this.gemsReward,
    required this.minTasksCompleted,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isActive: json['is_active'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
      experienceReward: json['experience_reward'] as int,
      coinsReward: json['coins_reward'] as int,
      gemsReward: json['gems_reward'] as int,
      minTasksCompleted: json['min_tasks_completed'] as int,
    );
  }
}
