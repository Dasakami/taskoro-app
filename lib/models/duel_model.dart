class UserSummary {
  final int id;
  final String username;
  final String avatar; // optional, может быть пустой строкой

  UserSummary({
    required this.id,
    required this.username,
    this.avatar = '',
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown',
      avatar: json['avatar'] ?? '',
    );
  }
}

class DuelModel {
  final int id;
  final UserSummary challenger;
  final UserSummary opponent;
  final int task;          // task id
  final int coinsStake;
  final String status;
  final DateTime createdAt;
  final DateTime? startTime;  // nullable
  final DateTime? endTime;    // nullable
  final int? winner;          // nullable (id победителя)

  DuelModel({
    required this.id,
    required this.challenger,
    required this.opponent,
    required this.task,
    required this.coinsStake,
    required this.status,
    required this.createdAt,
    this.startTime,
    this.endTime,
    this.winner,
  });

  factory DuelModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseNullableDate(String? dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr);
    }

    return DuelModel(
      id: json['id'] ?? 0,
      challenger: UserSummary.fromJson(json['challenger'] ?? {}),
      opponent: UserSummary.fromJson(json['opponent'] ?? {}),
      task: json['task'] ?? 0,
      coinsStake: json['coins_stake'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      startTime: parseNullableDate(json['start_time']),
      endTime: parseNullableDate(json['end_time']),
      winner: json['winner'],
    );
  }
}
