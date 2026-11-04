import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planz/providers/task_notifier.dart';

void main() {
  test('toMap/fromMap round trip keeps every field', () {
    final task = Task(
      task: 'Write report',
      desc: 'Q4',
      createdAt: DateTime(2026, 11, 1, 9),
      deletedAt: DateTime(2026, 11, 2),
      priority: TaskPriority.urgent,
      scheduledate: DateTime(2026, 11, 5),
      scheduletime: const TimeOfDay(hour: 14, minute: 45),
      isCompleted: true,
    );
    final copy = Task.fromMap(task.toMap());
    expect(copy.toMap(), task.toMap());
    expect(copy.id, task.id);
  });

  test('restore clears deletedAt (copyWith null bug)', () {
    final n = TaskNotifier();
    final t = n.addTask('A', '', TaskPriority.low);
    n.deleteTask(t.id);
    expect(n.state.single.isDeleted, isTrue);
    n.restoreTask(t.id);
    expect(n.state.single.isDeleted, isFalse);
  });

  test('operations target the right task by id after the list changes', () {
    final n = TaskNotifier();
    final a = n.addTask('A', '', TaskPriority.low);
    final b = n.addTask('B', '', TaskPriority.low);
    final c = n.addTask('C', '', TaskPriority.low);
    n.permanentlyDeleteTask(a.id);
    n.toggleTaskCompletion(c.id);
    expect(n.state.map((t) => t.task), ['B', 'C']);
    expect(n.state.firstWhere((t) => t.id == b.id).isCompleted, isFalse);
    expect(n.state.firstWhere((t) => t.id == c.id).isCompleted, isTrue);
  });

  test('emptyTrash removes only deleted tasks', () {
    final n = TaskNotifier();
    final a = n.addTask('A', '', TaskPriority.low);
    n.addTask('B', '', TaskPriority.low);
    n.deleteTask(a.id);
    n.emptyTrash();
    expect(n.state.map((t) => t.task), ['B']);
  });

  test('updateTask can clear a schedule', () {
    final n = TaskNotifier();
    final t = n.addTask(
      'A',
      '',
      TaskPriority.low,
      scheduledate: DateTime(2026, 1, 1),
      scheduletime: const TimeOfDay(hour: 9, minute: 0),
    );
    n.updateTask(t.copyWith(clearScheduledate: true, clearScheduletime: true));
    expect(n.state.single.isscheduled, isFalse);
    expect(n.state.single.scheduletime, isNull);
  });

  test('overdue only for unfinished tasks past their due time', () {
    final now = DateTime(2026, 11, 4, 12);
    Task make({DateTime? date, TimeOfDay? time, bool done = false}) => Task(
      task: 'x',
      desc: '',
      createdAt: now,
      scheduledate: date,
      scheduletime: time,
      isCompleted: done,
    );
    expect(make(date: DateTime(2026, 11, 3)).isOverdue(now), isTrue);
    // Today with no time is due at end of day.
    expect(make(date: DateTime(2026, 11, 4)).isOverdue(now), isFalse);
    expect(
      make(
        date: DateTime(2026, 11, 4),
        time: const TimeOfDay(hour: 11, minute: 0),
      ).isOverdue(now),
      isTrue,
    );
    expect(make(date: DateTime(2026, 11, 3), done: true).isOverdue(now), isFalse);
    expect(make().isOverdue(now), isFalse);
  });
}
