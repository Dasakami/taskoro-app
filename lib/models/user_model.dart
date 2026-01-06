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

  final String? equippedBackground;
  final String? equippedAvatarFrameColor;
  final String? equippedTitle;

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
    this.equippedBackground,
    this.equippedAvatarFrameColor,
    this.equippedTitle,
  });

  double get experiencePercent =>
      experienceNeeded > 0 ? (experience / experienceNeeded * 100) : 0;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['user']?.toString() ?? json['username']?.toString() ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      experienceNeeded: json['experience_needed'] as int? ?? 100,
      coins: json['coins'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      bio: json['bio'] as String?,
      title: json['title'] as String?,
      themePreference: json['theme_preference'] as String?,
      medals: json['medals'] as List<dynamic>? ?? [],
      characterClasses: json['character_classes'] as List<dynamic>? ?? [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      equippedBackground: json['equipped_background'] as String?,
      equippedAvatarFrameColor: json['equipped_avatar_frame_color'] as String?,
      equippedTitle: json['equipped_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatarUrl,
      'avatar_url': avatarUrl,
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
      'equipped_background': equippedBackground,
      'equipped_avatar_frame_color': equippedAvatarFrameColor,
      'equipped_title': equippedTitle,
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
    String? equippedBackground,
    String? equippedAvatarFrame,
    String? equippedTitle,
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
      equippedBackground: equippedBackground ?? this.equippedBackground,
      equippedAvatarFrameColor: equippedAvatarFrame ?? this.equippedAvatarFrameColor,
      equippedTitle: equippedTitle ?? this.equippedTitle,
    );
  }
}