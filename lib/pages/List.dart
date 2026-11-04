import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/task_provider.dart';
import 'package:planz/providers/theme_provider.dart';

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key});

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Today',
    'This Week',
    'Overdue',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// The day a task belongs to: its scheduled date, or the day it was
  /// created when it has no schedule.
  DateTime _taskDay(Task t) {
    final d = t.scheduledate ?? t.createdAt;
    return DateTime(d.year, d.month, d.day);
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

    switch (_selectedFilter) {
      case 'Today':
        return tasks
            .where((t) => !t.isCompleted && _taskDay(t) == today)
            .toList();

      case 'This Week':
        return tasks.where((t) {
          final day = _taskDay(t);
          return !t.isCompleted &&
              !day.isBefore(startOfWeek) &&
              day.isBefore(startOfNextWeek);
        }).toList();

      case 'Overdue':
        return tasks.where((t) => t.isOverdue(now)).toList();

      case 'Completed':
        return tasks.where((t) => t.isCompleted).toList();

      default:
        return tasks;
    }
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: EdgeInsets.only(
              right: index == _filterOptions.length - 1 ? 0 : 12,
            ),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                filter,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.getCardColor(context)
                      : AppTheme.getSecondaryTextColor(context),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  HapticFeedback.lightImpact();
                }
              },
              backgroundColor: AppTheme.getCardColor(context),
              selectedColor: AppTheme.getTextColor(context),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.getTextColor(context)
                    : AppTheme.getBorderColor(context),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskStats(List<Task> activeTasks) {
    final completed = activeTasks.where((t) => t.isCompleted).length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${activeTasks.length}",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                Text(
                  "Total Tasks",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$completed",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "Completed",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${activeTasks.length - completed}",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                Text(
                  "Pending",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 40,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No tasks found",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'All'
                  ? "Create your first task to get started"
                  : "No tasks match the current filter",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskNotifier = ref.read(taskProvider.notifier);
    final activeTasks = ref.watch(tasksSortedByPriorityProvider);

    // Filter based on selection
    final filteredTasks = _getFilteredTasks(activeTasks);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header without date and time
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title and subtitle
                Text(
                  "All Tasks",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage and organize all your tasks",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Filter chips
          _buildFilterChips(),

          // Task stats
          if (activeTasks.isNotEmpty) _buildTaskStats(activeTasks),

          // Task list
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedFilter == 'All'
                                  ? "All Tasks (${filteredTasks.length})"
                                  : "$_selectedFilter (${filteredTasks.length})",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                            if (filteredTasks.isNotEmpty)
                              Text(
                                "Tap to complete · swipe to delete",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeController,
                          child: ListView.builder(
                            itemCount: filteredTasks.length,
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Dismissible(
                                  key: ValueKey(task.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    HapticFeedback.mediumImpact();
                                    taskNotifier.deleteTask(task.id);
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    messenger.hideCurrentSnackBar();
                                    {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  "Task moved to trash",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  taskNotifier.restoreTask(
                                                    task.id,
                                                  );
                                                  messenger
                                                      .hideCurrentSnackBar();
                                                },
                                                child: Text(
                                                  "UNDO",
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.red.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      taskNotifier.toggleTaskCompletion(
                                        task.id,
                                      );
                                    },
                                    child: TaskCard(task: task),
                                  ),
                                ),
                              );
                            },
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
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  String _createdAgo() {
    final diff = DateTime.now().difference(task.createdAt);
    if (diff.inMinutes < 1) return "Created just now";
    if (diff.inHours < 1) return "Created ${diff.inMinutes}m ago";
    if (diff.inDays < 1) return "Created ${diff.inHours}h ago";
    if (diff.inDays < 7) return "Created ${diff.inDays}d ago";
    return "Created ${DateFormat('MMM d').format(task.createdAt)}";
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final overdue = task.isOverdue();
    final textColor = AppTheme.getTextColor(context);
    final muted = AppTheme.getSecondaryTextColor(context);

    final (statusLabel, statusColor) = isCompleted
        ? ("Completed", Colors.green)
        : overdue
        ? ("Overdue", Colors.red)
        : ("Pending", Colors.orange.shade700);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.task,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? muted : textColor,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.desc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.desc,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isCompleted ? Colors.grey.shade400 : muted,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Priority badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: task.priority.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      task.priority.icon,
                      size: 14,
                      color: task.priority.color,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      task.priority.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: task.priority.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (task.scheduledate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: overdue ? Colors.red : muted,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM dd, yyyy').format(task.scheduledate!) +
                      (task.scheduletime != null
                          ? ' · ${task.scheduletime!.format(context)}'
                          : ''),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: overdue ? Colors.red : muted,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _createdAgo(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
