import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  String _formatCurrentDuration(int totalSeconds) {
    if (totalSeconds == 0) return "0s";
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return "${hours}h${minutes.toString().padLeft(2, '0')}min${seconds.toString().padLeft(2, '0')}s";
    } else if (minutes > 0) {
      return "${minutes}min${seconds.toString().padLeft(2, '0')}s";
    } else {
      return "${seconds}s";
    }
  }

  String _formatPastDuration(int totalMinutes) {
    if (totalMinutes == 0) return "0min";
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return "${hours}h${minutes.toString().padLeft(2, '0')}min";
    } else {
      return "${minutes}min";
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

    final bool isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

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
                    physics: isDesktop ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 7 : 2, 
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: isDesktop 
                          ? ((constraints.maxWidth / 7) / ((constraints.maxHeight - 8) / 2))
                          : ((constraints.maxWidth / 2) / 120),
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
                            'duration': _formatCurrentDuration(task.trackedSeconds),
                          });
                        }
                      } else {
                        final snapshot = taskProvider.getSnapshotForDate(dateStr);
                        if (snapshot != null) {
                          for (var entry in snapshot.tasks.entries) {
                            if (entry.value > 0) {
                              displayLogs.add({
                                'name': entry.key,
                                'duration': _formatPastDuration(entry.value),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    dateStr == todayDateStr ? "Today" : _formatDate(date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      height: 1.2,
                                      color: dateStr == todayDateStr ? const Color(0xFF3daee9) : const Color(0xFFeff0f1),
                                    ),
                                  ),
                                ),
                                if (displayLogs.isNotEmpty)
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFFbdc3c7)),
                                      tooltip: 'Options',
                                      color: const Color(0xFF232629),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      onSelected: (val) {
                                        if (val == 'clear') {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: const Color(0xFF31363b),
                                              title: const Text('Clear Day', style: TextStyle(color: Color(0xFFeff0f1))),
                                              content: const Text('Are you sure you want to clear all tracked time for this day?\nThis cannot be undone.', style: TextStyle(color: Color(0xFFbdc3c7))),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text('Cancel', style: TextStyle(color: Color(0xFFbdc3c7))),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    context.read<TaskProvider>().clearDay(dateStr);
                                                    Navigator.pop(ctx);
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                                                  child: const Text('Clear'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'clear',
                                          height: 32,
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 16, color: Colors.redAccent),
                                              SizedBox(width: 8),
                                              Text('Clear Day', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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
