import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planz/pages/PageNav.dart';
import 'package:planz/pages/deleted_pages.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/task_provider.dart';
import 'package:planz/providers/theme_provider.dart';
import 'package:planz/providers/user_provider.dart';

enum _HomeFilter { all, pending, done }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _HomeFilter _filter = _HomeFilter.all;

  TaskNotifier get _notifier => ref.read(taskProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userProvider);
    final activeTasks = ref.watch(tasksSortedByPriorityProvider);
    final pending = activeTasks.where((t) => !t.isCompleted).toList();
    final done = activeTasks.where((t) => t.isCompleted).toList();
    final trashCount = ref.watch(deletedTasksProvider).length;

    final visible = switch (_filter) {
      _HomeFilter.all => [...pending, ...done], // unfinished first
      _HomeFilter.pending => pending,
      _HomeFilter.done => done,
    };

    final textColor = AppTheme.getTextColor(context);
    final now = DateTime.now();

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Text(
                      "PLANZ",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    _circleButton(
                      icon: Icons.search,
                      onTap: () => _openSearch(activeTasks),
                    ),
                    const SizedBox(width: 12),
                    _trashButton(trashCount),
                  ],
                ),
              ),

              // Greeting
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  "Hi, $name 👋",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ),

              // Filter tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    _buildFilterTab(
                      "All Tasks",
                      activeTasks.length,
                      _HomeFilter.all,
                    ),
                    const SizedBox(width: 12),
                    _buildFilterTab(
                      "Pending",
                      pending.length,
                      _HomeFilter.pending,
                    ),
                    const SizedBox(width: 12),
                    _buildFilterTab("Done", done.length, _HomeFilter.done),
                  ],
                ),
              ),

              // Today heading
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${now.day} ${_monthNames[now.month - 1].toUpperCase()} ${_dayNames[now.weekday - 1].toUpperCase()}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Today",
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Task list
              if (visible.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final task = visible[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: _deleteBackground(),
                      onDismissed: (_) => _deleteWithUndo(task),
                      child: GestureDetector(
                        onTap: () => _editTask(task),
                        child: _buildTaskItem(task),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Actions -------------------------------------------------------------

  void _toggle(Task task) {
    HapticFeedback.lightImpact();
    final wasLastPending =
        !task.isCompleted &&
        ref.read(pendingTasksProvider).every((t) => t.id == task.id);
    _notifier.toggleTaskCompletion(task.id);
    if (wasLastPending) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showCompletionSheet();
      });
    }
  }

  void _deleteWithUndo(Task task) {
    HapticFeedback.mediumImpact();
    _notifier.deleteTask(task.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          "Task moved to trash",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.white,
          onPressed: () => _notifier.restoreTask(task.id),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _editTask(Task task) async {
    final result = await showTaskSheet(context, task: task);
    if (result == null || !mounted) return;
    final date = result["date"] as DateTime?;
    final time = result["time"] as TimeOfDay?;
    _notifier.updateTask(
      task.copyWith(
        task: result["task"] as String,
        desc: result["desc"] as String,
        priority: result["priority"] as TaskPriority,
        scheduledate: date,
        scheduletime: time,
        clearScheduledate: date == null,
        clearScheduletime: time == null,
      ),
    );
  }

  Future<void> _openSearch(List<Task> tasks) async {
    final id = await showSearch<String?>(
      context: context,
      delegate: TaskSearch(tasks),
    );
    if (id == null || !mounted) return;
    final match = ref.read(activeTasksProvider).where((t) => t.id == id);
    if (match.isNotEmpty) _editTask(match.first);
  }

  void _showDeletedTasksSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeletedTasksSheet(),
    );
  }

  // ---- Widgets -------------------------------------------------------------

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.getBorderColor(context),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.getSecondaryTextColor(context),
        ),
      ),
    );
  }

  Widget _trashButton(int count) {
    final hasItems = count > 0;
    return GestureDetector(
      onTap: _showDeletedTasksSheet,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: hasItems
              ? Colors.red.shade50
              : AppTheme.getBorderColor(context),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: hasItems
                    ? Colors.red.shade600
                    : AppTheme.getSecondaryTextColor(context),
              ),
            ),
            if (hasItems)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, int count, _HomeFilter filter) {
    final isSelected = _filter == filter;
    final accent = AppTheme.getTextColor(context);
    final onAccent = AppTheme.getCardColor(context);
    final muted = AppTheme.getSecondaryTextColor(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filter = filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? onAccent : muted,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? onAccent.withValues(alpha: 0.2)
                      : AppTheme.getBorderColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? onAccent : muted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
    );
  }

  Widget _buildTaskItem(Task task) {
    final color = task.priority.color;
    final isCompleted = task.isCompleted;
    final overdue = task.isOverdue();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft glow from the priority line
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.10),
                    color.withValues(alpha: 0.05),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                // Priority line
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Completion checkbox (larger hit area than the visual circle)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggle(task),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? color : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? color
                                : color.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.task,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isCompleted
                                ? Colors.grey.shade400
                                : AppTheme.getTextColor(context),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (task.desc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.desc,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                        if (task.isscheduled) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 13,
                                color: overdue
                                    ? Colors.red
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDue(task) +
                                    (overdue ? " · Overdue" : ""),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: overdue
                                      ? Colors.red
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDue(Task task) {
    final d = task.scheduledate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    final day = switch (diff) {
      0 => "Today",
      1 => "Tomorrow",
      -1 => "Yesterday",
      _ => "${d.day} ${_monthNames[d.month - 1]}",
    };
    return task.scheduletime == null
        ? day
        : "$day, ${task.scheduletime!.format(context)}";
  }

  Widget _buildEmptyState() {
    final (title, subtitle) = switch (_filter) {
      _HomeFilter.done => (
        "Nothing completed yet",
        "Tap a task's circle to complete it",
      ),
      _ => ("No tasks yet", "Tap + to add your first task"),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.getBorderColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            const Icon(Icons.check_circle, size: 56, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              "All tasks completed",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Great job! Time to relax",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getTextColor(context),
                  foregroundColor: AppTheme.getCardColor(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Searches active tasks by title and description. Returns the chosen
/// task's id (or null when dismissed).
class TaskSearch extends SearchDelegate<String?> {
  final List<Task> tasks;
  TaskSearch(this.tasks);

  @override
  String get searchFieldLabel => 'Search tasks';

  List<Task> get _matches {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return tasks;
    return tasks
        .where(
          (t) =>
              t.task.toLowerCase().contains(q) ||
              t.desc.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(onPressed: () => query = "", icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final matches = _matches;
    if (matches.isEmpty) {
      return const Center(child: Text("No tasks found"));
    }
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final task = matches[index];
        return ListTile(
          leading: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.priority.color,
          ),
          title: Text(task.task),
          subtitle: task.desc.isEmpty ? null : Text(task.desc),
          onTap: () => close(context, task.id),
        );
      },
    );
  }
}
