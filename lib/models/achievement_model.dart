class Achievement {
  final int id;
  final String name;
  final String description;
  final String icon;
  final int experienceReward;
  final int coinsReward;
  final int gemsReward;
  final bool isAcquired;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.experienceReward,
    required this.coinsReward,
    required this.gemsReward,
    this.isAcquired = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      experienceReward: json['experience_reward'],
      coinsReward: json['coins_reward'],
      gemsReward: json['gems_reward'],
      isAcquired: json['is_acquired'] ?? false,
    );
  }
}
