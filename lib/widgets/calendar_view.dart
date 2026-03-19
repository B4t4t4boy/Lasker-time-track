import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return "0s";
    final duration = Duration(seconds: totalSeconds);
    if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s";
    } else {
      return "${duration.inSeconds}s";
    }
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${days[date.weekday - 1]}\n${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final List<AppTask> tasks = taskProvider.tasks;

    final now = DateTime.now();
    final String todayDateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    // Generate 14 days chronologically (Oldest first, today last)
    final List<DateTime> twoWeeks = List.generate(14, (i) => now.subtract(Duration(days: 13 - i)));

    return Container(
      height: 380, // Expanded height strictly structured for 2 perfect geometric lines
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '14-Day Calendar Log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                Text(
                  'Snapshotting Cumulative Task Timers',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, // Locks it down horizontally to precisely 7 days
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      // Dynamically resolves strict geometric proportions mapping layout height perfectly fitting exactly 2 rows
                      childAspectRatio: (constraints.maxWidth / 7) / ((constraints.maxHeight - 8) / 2),
                    ),
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final date = twoWeeks[index];
                      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      
                      final loggedTasks = tasks.where((t) => (t.dailyLogs[dateStr] ?? 0) > 0).toList();

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: dateStr == todayDateStr
                              ? Border.all(color: Colors.blueAccent.withOpacity(0.6), width: 2)
                              : Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr == todayDateStr ? "Today" : _formatDate(date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.2,
                                color: dateStr == todayDateStr ? Colors.blueAccent : Colors.black87,
                              ),
                            ),
                            const Divider(height: 12),
                            if (loggedTasks.isEmpty)
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "-", 
                                    style: TextStyle(color: Colors.grey, fontSize: 12)
                                  )
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  itemCount: loggedTasks.length,
                                  itemBuilder: (context, i) {
                                    final task = loggedTasks[i];
                                    final seconds = task.dailyLogs[dateStr]!;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              task.name,
                                              style: const TextStyle(fontSize: 11, color: Colors.black87),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDuration(seconds),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
