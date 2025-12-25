import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, urgent }

extension TaskPriorityExtension on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String get name => label;

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }
}

class Task {
  final String task;
  final String desc;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final TaskPriority priority;
  final DateTime? scheduledate;
  final TimeOfDay? scheduletime;
  final bool isCompleted;

  Task({
    required this.task,
    required this.desc,
    required this.createdAt,
    this.deletedAt,
    this.priority = TaskPriority.low,
    this.scheduletime,
    this.scheduledate,
    this.isCompleted = false,
  });

  // Updated toMap method
  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'desc': desc,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'priority': priority.index,
      'scheduledate': scheduledate?.toIso8601String(),
      'scheduletimehour': scheduletime?.hour,
      'scheduletimeminute': scheduletime?.minute,
      'isCompleted': isCompleted,
    };
  }

  // Updated fromMap method
  factory Task.fromMap(Map<String, dynamic> map) {
    TimeOfDay? scheduletime;
    if (map['scheduletimehour'] != null && map['scheduletimeminute'] != null) {
      scheduletime = TimeOfDay(
        hour: map['scheduletimehour'],
        minute: map['scheduletimeminute'],
      );
    }
    return Task(
      task: map['task'] ?? '',
      desc: map['desc'] ?? '',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null && map['deletedAt'] is String
          ? DateTime.parse(map['deletedAt'])
          : null,
      priority: map['priority'] != null
          ? TaskPriority.values[map['priority']]
          : TaskPriority.low,
      scheduledate: map['scheduledate'] != null && map['scheduledate'] is String
          ? DateTime.parse(map['scheduledate'])
          : null,
      scheduletime: scheduletime,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Updated copyWith method
  Task copyWith({
    String? task,
    String? desc,
    DateTime? createdAt,
    DateTime? deletedAt,
    TaskPriority? priority,
    DateTime? scheduledate,
    TimeOfDay? scheduletime,
    bool? isCompleted,
  }) {
    return Task(
      task: task ?? this.task,
      desc: desc ?? this.desc,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      priority: priority ?? this.priority,
      scheduledate: scheduledate ?? this.scheduledate,
      scheduletime: scheduletime ?? this.scheduletime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool get isscheduled => scheduledate != null;

  bool get isScheduledForToday {
    if (scheduledate == null) return false;
    final today = DateTime.now();
    return scheduledate!.year == today.year &&
        scheduledate!.month == today.month &&
        scheduledate!.day == today.day;
  }
bool isScheduledForDate(DateTime date) {
  if (scheduledate == null) return false;
  
  // Strip time and timezone info, compare only date components
  final taskYear = scheduledate!.year;
  final taskMonth = scheduledate!.month; 
  final taskDay = scheduledate!.day;
  
  final searchYear = date.year;
  final searchMonth = date.month;
  final searchDay = date.day;
  
  print("DEBUG: Task date parts: $taskYear-$taskMonth-$taskDay");
  print("DEBUG: Search date parts: $searchYear-$searchMonth-$searchDay");
  
  return taskYear == searchYear && taskMonth == searchMonth && taskDay == searchDay;
}
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  // Updated addTask method with priority
  void addTask(
    String taskTitle,
    String taskDesc,
    TaskPriority priority, {
    DateTime? scheduledate,
    TimeOfDay? scheduletime,
  }) {
    final newTask = Task(
      task: taskTitle,
      desc: taskDesc,
      createdAt: DateTime.now(),
      priority: priority,
      scheduledate: scheduledate,
      scheduletime: scheduletime,
    );
    state = [...state, newTask];
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < state.length) {
      final updatedTask = state[index].copyWith(
        isCompleted: !state[index].isCompleted,
      );
      final newState = List<Task>.from(state);
      newState[index] = updatedTask;
      state = newState;
    }
  }

  // Rest of your existing methods remain the same...
  void removeTask(int index) {
    if (index >= 0 && index < state.length) {
      final updatedTask = state[index].copyWith(deletedAt: DateTime.now());
      final newState = List<Task>.from(state);
      newState[index] = updatedTask;
      state = newState;
    }
  }

  void deleteTask(int index) {
    removeTask(index);
  }

  void restoreTask(int index) {
    if (index >= 0 && index < state.length) {
      final updatedTask = state[index].copyWith(deletedAt: null);
      final newState = List<Task>.from(state);
      newState[index] = updatedTask;
      state = newState;
    }
  }

  void permanentlyDeleteTask(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state.sublist(0, index), ...state.sublist(index + 1)];
    }
  }

  // New method to update task priority
  void updateTaskPriority(int index, TaskPriority newPriority) {
    if (index >= 0 && index < state.length) {
      final updatedTask = state[index].copyWith(priority: newPriority);
      final newState = List<Task>.from(state);
      newState[index] = updatedTask;
      state = newState;
    }
  }

  // Existing getters
  List<Task> get activeTasks {
    return state.where((task) => task.deletedAt == null).toList();
  }

  List<Task> get deletedTasks {
    return state.where((task) => task.deletedAt != null).toList();
  }

  List<Task> get todaysDeletedTasks {
    final today = DateTime.now();
    return deletedTasks.where((task) {
      if (task.deletedAt == null) return false;
      final deletedDate = task.deletedAt!;
      return deletedDate.year == today.year &&
          deletedDate.month == today.month &&
          deletedDate.day == today.day;
    }).toList();
  }

  // New getter to get tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return activeTasks.where((task) => task.priority == priority).toList();
  }

  List<Task> get scheduledTasks {
    return activeTasks.where((task) => task.isscheduled).toList();
  }

  List<Task> get todaysScheduledTasks {
    return activeTasks.where((task) => task.isScheduledForToday).toList();
  }

  List<Task> getTasksForDate(DateTime date) {
    return activeTasks.where((task) => task.isScheduledForDate(date)).toList();
  }

  // New getter to get tasks sorted by priority
  List<Task> get activeTasksSortedByPriority {
    final tasks = List<Task>.from(activeTasks);
    tasks.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    ); // Urgent first
    return tasks;
  }
}
