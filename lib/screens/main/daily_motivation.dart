class DailyMotivation {
  final int id;
  final String text;
  final String author;

  DailyMotivation({
    required this.id,
    required this.text,
    required this.author,
  });

  factory DailyMotivation.fromJson(Map<String, dynamic> json) {
    return DailyMotivation(
      // Если API не передаёт id, назначаем значение по умолчанию 0
      id: json['id'] ?? 0,
      // В ответе API для мотивации используется ключ "text"
      text: json['text'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
    };
  }
}
