import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/daily_snapshot_model.dart';

class TaskProvider with ChangeNotifier {
  List<AppTask> _tasks = [];
  Map<String, DailySnapshot> _snapshots = {};
  Timer? _timer;
  final String _storageKey = 'time_tracker_tasks';
  final String _snapshotStorageKey = 'time_tracker_snapshots';
  final String _lastOpenedDateKey = 'time_tracker_last_opened';

  int _secondsSinceSnapshot = 0;

  List<AppTask> get tasks => _tasks;
  Map<String, DailySnapshot> get snapshots => _snapshots;

  TaskProvider() {
    _loadTasks();
    _startGlobalTimer();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  DailySnapshot? getSnapshotForDate(String dateStr) {
    return _snapshots[dateStr];
  }

  void _startGlobalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool hasActive = false;
      for (var task in _tasks) {
        if (task.state == TaskState.active) {
          task.trackedSeconds++;
          hasActive = true;
        }
      }
      if (hasActive) {
        notifyListeners();
        _saveTasks();
      }

      _secondsSinceSnapshot++;
      if (_secondsSinceSnapshot >= 60) {
        _takeSnapshot();
        _secondsSinceSnapshot = 0;
      }
    });
  }

  void _takeSnapshot() {
    final todayDate = _getTodayDateString();
    Map<String, int> loggedMinutes = {};
    for (var task in _tasks) {
      if (task.trackedSeconds >= 60) {
        loggedMinutes[task.name] = task.trackedSeconds ~/ 60;
      }
    }
    
    _snapshots[todayDate] = DailySnapshot(date: todayDate, tasks: loggedMinutes);
    _saveSnapshots();
  }

  void addTask(String name) {
    final newTask = AppTask(id: const Uuid().v4(), name: name);
    _tasks.add(newTask);
    _saveTasks();
    _takeSnapshot();
    notifyListeners();
  }

  void toggleTaskState(String id) {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    if (task.state == TaskState.idle || task.state == TaskState.stopped) {
      task.state = TaskState.active;
    } else if (task.state == TaskState.active) {
      task.state = TaskState.stopped;
    }
    _saveTasks();
    notifyListeners();
  }

  void updateTaskName(String id, String newName) {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].name = newName;
      _saveTasks();
      _takeSnapshot();
      notifyListeners();
    }
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    _takeSnapshot();
    notifyListeners();
  }

  void resetTaskTimer(String id) {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].trackedSeconds = 0;
      _saveTasks();
      _takeSnapshot();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_storageKey, tasksJson);
  }

  Future<void> _saveSnapshots() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshotsJson = _snapshots.values.map((s) => s.toJson()).toList();
    await prefs.setStringList(_snapshotStorageKey, snapshotsJson);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Snapshots
    final snapshotsJson = prefs.getStringList(_snapshotStorageKey) ?? [];
    for (var jsonStr in snapshotsJson) {
      final snapshot = DailySnapshot.fromJson(jsonStr);
      _snapshots[snapshot.date] = snapshot;
    }

    final tasksJson = prefs.getStringList(_storageKey) ?? [];
    _tasks = tasksJson.map((json) => AppTask.fromJson(json)).toList();
    
    final todayDate = _getTodayDateString();
    final lastOpened = prefs.getString(_lastOpenedDateKey);

    if (lastOpened != null && lastOpened != todayDate) {
      for (var task in _tasks) {
        task.trackedSeconds = 0;
        task.state = TaskState.idle;
      }
      _saveTasks();
    }
    await prefs.setString(_lastOpenedDateKey, todayDate);
    
    _takeSnapshot();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
