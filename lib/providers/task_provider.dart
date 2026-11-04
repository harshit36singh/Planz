import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:planz/providers/task_notifier.dart';

/// Source of truth for all tasks, persisted to the Hive "todo" box
/// (opened in `main()` before the app starts).
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final box = Hive.isBoxOpen(TaskNotifier.boxName)
      ? Hive.box(TaskNotifier.boxName)
      : null;
  return TaskNotifier(box);
});

// Derived views over the task list.

final activeTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskProvider).where((task) => !task.isDeleted).toList();
});

final deletedTasksProvider = Provider<List<Task>>((ref) {
  final deleted = ref
      .watch(taskProvider)
      .where((task) => task.isDeleted)
      .toList();
  // Most recently deleted first.
  deleted.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
  return deleted;
});

final completedTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(activeTasksProvider).where((t) => t.isCompleted).toList();
});

final pendingTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(activeTasksProvider).where((t) => !t.isCompleted).toList();
});

final scheduledTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(activeTasksProvider).where((t) => t.isscheduled).toList();
});

final todaysScheduledTasksProvider = Provider<List<Task>>((ref) {
  return ref
      .watch(activeTasksProvider)
      .where((t) => t.isScheduledForToday)
      .toList();
});

/// Active tasks scheduled on [date] (time of day ignored), sorted by time.
final tasksForDateProvider = Provider.family<List<Task>, DateTime>((ref, date) {
  final tasks = ref
      .watch(activeTasksProvider)
      .where((t) => t.isScheduledForDate(date))
      .toList();
  tasks.sort((a, b) {
    final am = a.scheduletime == null
        ? -1
        : a.scheduletime!.hour * 60 + a.scheduletime!.minute;
    final bm = b.scheduletime == null
        ? -1
        : b.scheduletime!.hour * 60 + b.scheduletime!.minute;
    return am.compareTo(bm);
  });
  return tasks;
});

/// Active tasks, urgent first.
final tasksSortedByPriorityProvider = Provider<List<Task>>((ref) {
  final sorted = List<Task>.from(ref.watch(activeTasksProvider));
  sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  return sorted;
});
