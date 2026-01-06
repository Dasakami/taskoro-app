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
    final profile = json['friend_profile'] as Map<String, dynamic>?;

    if (profile != null) {
      final user = profile['user'];
      String username = user is String ? user : 'Неизвестный';
      String? avatar = profile['avatar'] as String?;

      return Friend(
        id: json['id'] as int? ?? 0,
        username: username,
        avatarUrl: avatar,
        level: profile['level'] as int? ?? 1,
        experience: profile['experience'] as int? ?? 0,
      );
    }

    return Friend(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? 'Неизвестный',
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
    );
  }
}

class FriendRequest {
  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final int level;

  FriendRequest({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.level,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json, {required bool isReceived}) {
    final key = isReceived ? 'sender' : 'receiver';
    final container = json[key] as Map<String, dynamic>?;

    String username = 'Неизвестный';
    String? avatar;
    int userId = 0;
    int level = 1;

    if (container != null) {
      final user = container['user'];
      username = user is String ? user : 'Неизвестный';
      avatar = container['avatar'] as String?;
      // ИСПРАВЛЕНО: userId берем из profile.id, а не из container.id
      userId = container['user_id'] as int? ?? container['id'] as int? ?? 0;
      level = container['level'] as int? ?? 1;
    }

    return FriendRequest(
      id: json['id'] as int? ?? 0,
      userId: userId,
      username: username,
      avatarUrl: avatar,
      level: level,
    );
  }

  FriendRequest copyWith({
    String? username,
    String? avatarUrl,
    int? level,
  }) {
    return FriendRequest(
      id: id,
      userId: userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
    );
  }
}