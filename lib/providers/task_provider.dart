import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<AppTask> _tasks = [];
  Timer? _timer;
  final String _storageKey = 'time_tracker_tasks';

  List<AppTask> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
    _startGlobalTimer();
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
    });
  }

  void addTask(String name) {
    final newTask = AppTask(id: const Uuid().v4(), name: name);
    _tasks.add(newTask);
    _saveTasks();
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
      notifyListeners();
    }
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_storageKey, tasksJson);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_storageKey) ?? [];
    _tasks = tasksJson.map((json) => AppTask.fromJson(json)).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
