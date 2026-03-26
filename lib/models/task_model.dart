import 'dart:convert';

enum TaskState { idle, active, stopped }

class AppTask {
  final String id;
  String name;
  int trackedSeconds;
  TaskState state;

  AppTask({
    required this.id,
    required this.name,
    this.trackedSeconds = 0,
    this.state = TaskState.idle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'trackedSeconds': trackedSeconds,
      'state': state.index,
    };
  }

  factory AppTask.fromMap(Map<String, dynamic> map) {
    return AppTask(
      id: map['id'],
      name: map['name'],
      trackedSeconds: map['trackedSeconds'] ?? 0,
      state: TaskState.values[map['state'] ?? 0],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppTask.fromJson(String source) => AppTask.fromMap(json.decode(source));
}
