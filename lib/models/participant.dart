class Participant {
  final int id;
  final String username;
  final int score;
  final int tasksCompleted;

  Participant({
    required this.id,
    required this.username,
    required this.score,
    required this.tasksCompleted,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      username: json['user_username'],
      score: json['score'],
      tasksCompleted: json['tasks_completed'],
    );
  }
}
