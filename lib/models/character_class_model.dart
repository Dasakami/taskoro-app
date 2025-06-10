class CharacterClassModel {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String color;

  CharacterClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory CharacterClassModel.fromJson(Map<String, dynamic> json) {
    return CharacterClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}
