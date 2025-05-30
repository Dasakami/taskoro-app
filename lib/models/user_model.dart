class UserModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final int level;
  final int experience;
  final int experienceNeeded;
  final int coins;
  final int gems;
  final int streak;

  final String? bio;
  final String? title;
  final String? themePreference;
  final List<dynamic> medals;
  final List<dynamic> characterClasses;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.level = 1,
    this.experience = 0,
    this.experienceNeeded = 100,
    this.coins = 0,
    this.gems = 0,
    this.streak = 0,
    this.bio,
    this.title,
    this.themePreference,
    this.medals = const [],
    this.characterClasses = const [],
    this.createdAt,
    this.updatedAt,
  });

  double get experiencePercent =>
      experienceNeeded > 0 ? (experience / experienceNeeded * 100) : 0;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['user'] ?? json['username'],
      avatarUrl: json['avatar'],
      level: json['level'],
      experience: json['experience'],
      experienceNeeded: json['experience_needed'],
      coins: json['coins'],
      gems: json['gems'],
      streak: json['streak'],
      bio: json['bio'],
      title: json['title'],
      themePreference: json['theme_preference'],
      medals: json['medals'] ?? [],
      characterClasses: json['character_classes'] ?? [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatarUrl,
      'level': level,
      'experience': experience,
      'experience_needed': experienceNeeded,
      'coins': coins,
      'gems': gems,
      'streak': streak,
      'bio': bio,
      'title': title,
      'theme_preference': themePreference,
      'medals': medals,
      'character_classes': characterClasses,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    int? level,
    int? experience,
    int? experienceNeeded,
    int? coins,
    int? gems,
    int? streak,
    String? bio,
    String? title,
    String? themePreference,
    List<dynamic>? medals,
    List<dynamic>? characterClasses,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      experienceNeeded: experienceNeeded ?? this.experienceNeeded,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      bio: bio ?? this.bio,
      title: title ?? this.title,
      themePreference: themePreference ?? this.themePreference,
      medals: medals ?? this.medals,
      characterClasses: characterClasses ?? this.characterClasses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
