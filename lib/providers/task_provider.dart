import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:planz/providers/task_notifier.dart';

// Main provider (new API)
final task_provider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// Computed providers for easy access
final activeTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(task_provider);
  return tasks.where((task) => task.deletedAt == null).toList();
});

final deletedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(task_provider);
  return tasks.where((task) => task.deletedAt != null).toList();
});

final todaysDeletedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(task_provider);
  final today = DateTime.now();
  return tasks
      .where((task) {
        if (task.deletedAt == null) return false;
        final deletedDate = task.deletedAt!;
        return deletedDate.year == today.year &&
            deletedDate.month == today.month &&
            deletedDate.day == today.day;
      })
      .where((task) => task.deletedAt != null)
      .toList();
});

final scheduledTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(activeTasksProvider);
  return tasks.where((task) => task.isscheduled).toList();
});

final todaysScheduledTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(activeTasksProvider);
  return tasks.where((task) => task.isScheduledForToday).toList();
});

// FIXED Provider factory for tasks on specific dates
final tasksForDateProvider = Provider.family<List<Task>, DateTime>((ref, date) {
  final tasks = ref.watch(activeTasksProvider);
  
  print("DEBUG Provider: Looking for tasks on date: ${date.year}-${date.month}-${date.day}");
  print("DEBUG Provider: Total active tasks: ${tasks.length}");
  
  final matchingTasks = <Task>[];
  
  for (final task in tasks) {
    if (task.scheduledate != null) {
      final taskDate = task.scheduledate!;
      print("DEBUG Provider: Task '${task.task}' scheduled for: ${taskDate.year}-${taskDate.month}-${taskDate.day}");
      
      // Simple date comparison - ignore time/timezone
      if (taskDate.year == date.year && 
          taskDate.month == date.month && 
          taskDate.day == date.day) {
        matchingTasks.add(task);
        print("DEBUG Provider: MATCH FOUND for task '${task.task}'");
      }
    }
  }
  
  print("DEBUG Provider: Found ${matchingTasks.length} matching tasks");
  return matchingTasks;
});

// Provider for tasks sorted by priority
final tasksSortedByPriorityProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(activeTasksProvider);
  final sortedTasks = List<Task>.from(tasks);
  sortedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  return sortedTasks;
});