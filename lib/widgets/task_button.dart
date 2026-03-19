import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskButton extends StatelessWidget {
  final AppTask task;

  const TaskButton({Key? key, required this.task}) : super(key: key);

  Color _getButtonColor() {
    switch (task.state) {
      case TaskState.idle:
        return const Color(0xFF31363b); // KDE Surface Dark
      case TaskState.active:
        return Colors.green.shade700;
      case TaskState.stopped:
        return Colors.red.shade700;
    }
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showRenameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: task.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF31363b),
          titleTextStyle: const TextStyle(color: Color(0xFFeff0f1), fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: const TextStyle(color: Color(0xFFeff0f1)),
          title: const Text('Rename Task'),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFFeff0f1)),
            decoration: const InputDecoration(
              hintText: 'Enter new task name',
              hintStyle: TextStyle(color: Colors.white30),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                context.read<TaskProvider>().updateTaskName(task.id, value.trim());
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFbdc3c7))),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<TaskProvider>().updateTaskName(task.id, controller.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3daee9), foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF31363b),
        title: const Text('Delete Task', style: TextStyle(color: Color(0xFFeff0f1))),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.', style: TextStyle(color: Color(0xFFbdc3c7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFbdc3c7))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskProvider>().removeTask(task.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF31363b),
        title: const Text('Reset Timer', style: TextStyle(color: Color(0xFFeff0f1))),
        content: const Text('Are you sure you want to reset the timer to 00:00:00?', style: TextStyle(color: Color(0xFFbdc3c7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFbdc3c7))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TaskProvider>().resetTaskTimer(task.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<TaskProvider>().toggleTaskState(task.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _getButtonColor(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    task.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFeff0f1),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDuration(task.trackedSeconds),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFeff0f1),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFFeff0f1)),
                tooltip: 'Options',
                color: const Color(0xFF232629), // KDE Menu Dark
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'rename') {
                    _showRenameDialog(context);
                  } else if (value == 'reset') {
                    _confirmReset(context);
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Color(0xFFeff0f1)),
                        SizedBox(width: 8),
                        Text('Rename', style: TextStyle(color: Color(0xFFeff0f1))),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Reset Timer', style: TextStyle(color: Color(0xFFeff0f1))),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
