import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../models/daily_snapshot_model.dart';

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
        color: const Color(0xFF31363b), // KDE Surface
        border: const Border(top: BorderSide(color: Color(0xFF1b1e20), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
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
                      
                      final isToday = dateStr == todayDateStr;
                      
                      final List<Map<String, String>> displayLogs = [];
                      
                      if (isToday) {
                        final activeToday = tasks.where((t) => t.trackedSeconds > 0).toList();
                        for (var task in activeToday) {
                          displayLogs.add({
                            'name': task.name,
                            'duration': _formatDuration(task.trackedSeconds),
                          });
                        }
                      } else {
                        final snapshot = taskProvider.getSnapshotForDate(dateStr);
                        if (snapshot != null) {
                          for (var entry in snapshot.tasks.entries) {
                            if (entry.value > 0) {
                              displayLogs.add({
                                'name': entry.key,
                                'duration': '${entry.value}m',
                              });
                            }
                          }
                        }
                      }

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232629), // KDE Background
                          borderRadius: BorderRadius.circular(12),
                          border: dateStr == todayDateStr
                              ? Border.all(color: const Color(0xFF3daee9), width: 2) // KDE Accent Blue
                              : Border.all(color: const Color(0xFF1b1e20), width: 1),
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
                                color: dateStr == todayDateStr ? const Color(0xFF3daee9) : const Color(0xFFeff0f1),
                              ),
                            ),
                            const Divider(height: 12, color: Color(0xFF31363b)),
                            if (displayLogs.isEmpty)
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "-", 
                                    style: TextStyle(color: Color(0xFFbdc3c7), fontSize: 12)
                                  )
                                )
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  itemCount: displayLogs.length,
                                  itemBuilder: (context, i) {
                                    final log = displayLogs[i];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              log['name']!,
                                              style: const TextStyle(fontSize: 11, color: Color(0xFFeff0f1)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            log['duration']!,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade400),
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
