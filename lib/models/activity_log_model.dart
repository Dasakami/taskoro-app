class ActivityLog {
  final String type;
  final String title;
  final String description;
  final String reward;
  final String timestamp;

  ActivityLog({
    required this.type,
    required this.title,
    required this.description,
    required this.reward,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Формируем строку награды
    String reward = '';
    final coins = json['coins_gained'] ?? 0;
    final experience = json['experience_gained'] ?? 0;
    final gems = json['gems_gained'] ?? 0;

    if (coins > 0) reward += '+$coins монет ';
    if (experience > 0) reward += '+$experience опыта ';
    if (gems > 0) reward += '+$gems самоцветов';

    reward = reward.trim();

    return ActivityLog(
      type: json['activity_type'] ?? '',
      title: json['activity_type_display'] ?? '',
      description: json['description'] ?? '',
      reward: reward.isNotEmpty ? reward : '-',
      timestamp: json['created_at'] ?? '',
    );
  }
}
