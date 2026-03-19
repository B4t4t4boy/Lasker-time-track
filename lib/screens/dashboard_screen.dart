import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_button.dart';
import '../widgets/calendar_view.dart';
import 'package:window_manager/window_manager.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter task name'),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                context.read<TaskProvider>().addTask(value.trim());
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<TaskProvider>().addTask(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: WindowCaption(
          title: Text('Time Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFeff0f1))),
          brightness: Brightness.dark,
          backgroundColor: Color(0xFF232629),
        ),
      ),
      backgroundColor: const Color(0xFF232629),
      body: Column(
        children: [
          Expanded(
            child: taskProvider.tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet. Create one to start tracking!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        // Reduced scale by 20%
                        maxCrossAxisExtent: 200, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        return TaskButton(task: taskProvider.tasks[index]);
                      },
                    ),
                  ),
          ),
          const CalendarView(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 390.0), // Safely push FAB above the 2-tier calendar
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: const Color(0xFF3daee9),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Task'),
        ),
      ),
    );
  }
}
