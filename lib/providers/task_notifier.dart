import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

int _idCounter = 0;
String _generateId() =>
    '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

class Task {
  /// Stable identifier. All notifier operations use this instead of list
  /// indexes, which go stale as soon as the list changes.
  final String id;
  final String task;
  final String desc;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final TaskPriority priority;
  final DateTime? scheduledate;
  final TimeOfDay? scheduletime;
  final bool isCompleted;

  Task({
    String? id,
    required this.task,
    required this.desc,
    required this.createdAt,
    this.deletedAt,
    this.priority = TaskPriority.medium,
    this.scheduletime,
    this.scheduledate,
    this.isCompleted = false,
  }) : id = id ?? _generateId();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  factory Task.fromMap(Map<String, dynamic> map) {
    TimeOfDay? scheduletime;
    if (map['scheduletimehour'] != null && map['scheduletimeminute'] != null) {
      scheduletime = TimeOfDay(
        hour: map['scheduletimehour'],
        minute: map['scheduletimeminute'],
      );
    }
    final priorityIndex = map['priority'];
    return Task(
      id: map['id'] as String?,
      task: map['task'] ?? '',
      desc: map['desc'] ?? '',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      deletedAt: map['deletedAt'] is String
          ? DateTime.parse(map['deletedAt'])
          : null,
      priority:
          priorityIndex is int &&
              priorityIndex >= 0 &&
              priorityIndex < TaskPriority.values.length
          ? TaskPriority.values[priorityIndex]
          : TaskPriority.medium,
      scheduledate: map['scheduledate'] is String
          ? DateTime.parse(map['scheduledate'])
          : null,
      scheduletime: scheduletime,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  /// The `clear*` flags exist because `null` can't be passed through `??`
  /// to remove a value (e.g. restoring a task must reset `deletedAt`).
  Task copyWith({
    String? task,
    String? desc,
    DateTime? deletedAt,
    TaskPriority? priority,
    DateTime? scheduledate,
    TimeOfDay? scheduletime,
    bool? isCompleted,
    bool clearDeletedAt = false,
    bool clearScheduledate = false,
    bool clearScheduletime = false,
  }) {
    return Task(
      id: id,
      task: task ?? this.task,
      desc: desc ?? this.desc,
      createdAt: createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      priority: priority ?? this.priority,
      scheduledate: clearScheduledate
          ? null
          : (scheduledate ?? this.scheduledate),
      scheduletime: clearScheduletime
          ? null
          : (scheduletime ?? this.scheduletime),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool get isDeleted => deletedAt != null;

  bool get isscheduled => scheduledate != null;

  bool get isScheduledForToday => isScheduledForDate(DateTime.now());

  bool isScheduledForDate(DateTime date) {
    if (scheduledate == null) return false;
    return scheduledate!.year == date.year &&
        scheduledate!.month == date.month &&
        scheduledate!.day == date.day;
  }

  /// The moment the task is due: its scheduled date plus time (end of day
  /// when no time is set). Null for unscheduled tasks.
  DateTime? get dueAt {
    if (scheduledate == null) return null;
    final d = scheduledate!;
    if (scheduletime == null) return DateTime(d.year, d.month, d.day, 23, 59);
    return DateTime(
      d.year,
      d.month,
      d.day,
      scheduletime!.hour,
      scheduletime!.minute,
    );
  }

  bool isOverdue([DateTime? now]) {
    final due = dueAt;
    if (due == null || isCompleted || isDeleted) return false;
    return due.isBefore(now ?? DateTime.now());
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  static const String boxName = 'todo';
  static const String _tasksKey = 'tasks';

  final Box? _box;

  /// Pass a Hive box to persist tasks; with no box the notifier is in-memory
  /// only (used by tests).
  TaskNotifier([this._box]) : super(_load(_box));

  static List<Task> _load(Box? box) {
    if (box == null) return [];
    final raw = box.get(_tasksKey);
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((m) => Task.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  @override
  set state(List<Task> value) {
    super.state = value;
    _box?.put(_tasksKey, value.map((t) => t.toMap()).toList());
  }

  void _update(String id, Task Function(Task) change) {
    state = [for (final t in state) t.id == id ? change(t) : t];
  }

  Task addTask(
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
    return newTask;
  }

  /// Replaces the task with the same id.
  void updateTask(Task updated) => _update(updated.id, (_) => updated);

  void toggleTaskCompletion(String id) =>
      _update(id, (t) => t.copyWith(isCompleted: !t.isCompleted));

  /// Soft delete: moves the task to the trash.
  void deleteTask(String id) =>
      _update(id, (t) => t.copyWith(deletedAt: DateTime.now()));

  void restoreTask(String id) =>
      _update(id, (t) => t.copyWith(clearDeletedAt: true));

  void permanentlyDeleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  /// Permanently removes every task currently in the trash.
  void emptyTrash() {
    state = state.where((t) => !t.isDeleted).toList();
  }

  void updateTaskPriority(String id, TaskPriority newPriority) =>
      _update(id, (t) => t.copyWith(priority: newPriority));

  void clearAll() {
    state = [];
  }
}
