class Exercise {
  const Exercise({required this.id, required this.title, required this.done});
  final String id;
  final String title;
  final bool done;

  factory Exercise.fromMap(Map<String, Object?> map) => Exercise(
    id: map['id'] as String, title: map['title'] as String,
    done: map['is_done'] == 1);
}
