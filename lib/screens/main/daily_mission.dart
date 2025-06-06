class DailyMission {
  final int id;
  final String title;
  final String description;
  final int experienceReward;
  final int coinsReward;
  final bool isCompleted;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.experienceReward,
    required this.coinsReward,
    required this.isCompleted,
  });

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      experienceReward: json['experience_reward'],
      coinsReward: json['coins_reward'],
      isCompleted: json['is_completed'],
    );
  }
}
