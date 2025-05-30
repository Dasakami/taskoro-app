class Friend {
  final int id;
  final String username;
  final String? avatarUrl;
  final int level;
  final int experience;

  Friend({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.experience,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    // Проверяем разные возможные структуры данных
    if (json.containsKey('friend_profile')) {
      final profile = json['friend_profile'] ?? {};
      return Friend(
        id: json['id'] ?? 0,
        username: profile['user'] ?? 'Unknown',
        avatarUrl: profile['avatar'],
        level: profile['level'] ?? 1,
        experience: profile['experience'] ?? 0,
      );
    } else {
      // Обычная структура для друзей
      return Friend(
        id: json['id'] ?? 0,
        username: json['username'] ?? 'Unknown',
        avatarUrl: json['avatar_url'] ?? json['avatar'], // на всякий случай
        level: json['level'] ?? 1,
        experience: json['experience'] ?? 0,
      );
    }
  }
}

class FriendRequest {
  final int id;
  final String username;
  final String? avatarUrl;
  final int level;

  FriendRequest({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.level,
  });

  // isReceived = true — это входящий запрос, тогда юзер в sender
  // isReceived = false — исходящий запрос, тогда юзер в receiver
  factory FriendRequest.fromJson(Map<String, dynamic> json, {required bool isReceived}) {
    final userData = isReceived ? json['sender'] : json['receiver'];

    return FriendRequest(
      id: json['id'],
      username: userData['username'] ?? 'Unknown',
      avatarUrl: userData['avatar'],
      level: userData['level'] ?? 1,
    );
  }
}
