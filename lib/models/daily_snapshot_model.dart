import 'dart:convert';

class DailySnapshot {
  final String date;
  final Map<String, int> tasks;

  DailySnapshot({
    required this.date,
    required this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'tasks': tasks,
    };
  }

  factory DailySnapshot.fromMap(Map<String, dynamic> map) {
    return DailySnapshot(
      date: map['date'],
      tasks: map['tasks'] != null 
          ? Map<String, int>.from(map['tasks'])
          : {},
    );
  }

  String toJson() => json.encode(toMap());

  factory DailySnapshot.fromJson(String source) => DailySnapshot.fromMap(json.decode(source));
}
