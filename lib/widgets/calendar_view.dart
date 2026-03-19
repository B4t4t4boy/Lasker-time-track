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
    return "${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final List<AppTask> tasks = taskProvider.tasks;

    final now = DateTime.now();
    final String todayDateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final List<DateTime> twoWeeks = List.generate(14, (i) => now.subtract(Duration(days: i)));

    return Container(
      height: 240,
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Activity Calendar (Last 14 Days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: twoWeeks.length,
              itemBuilder: (context, index) {
                final date = twoWeeks[index];
                final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                
                final loggedTasks = tasks.where((t) => (t.dailyLogs[dateStr] ?? 0) > 0).toList();

                return Container(
                  width: 170,
                  margin: const EdgeInsets.fromLTRB(12, 8, 4, 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: dateStr == todayDateStr
                        ? Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2)
                        : Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr == todayDateStr ? "Today" : _formatDate(date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: dateStr == todayDateStr ? Colors.blueAccent : Colors.black87,
                        ),
                      ),
                      const Divider(),
                      if (loggedTasks.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              "No activity", 
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)
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
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.name,
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(seconds),
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700),
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
            ),
          ),
        ],
      ),
    );
  }
}
