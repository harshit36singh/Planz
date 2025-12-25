import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planz/Widgets/bottom_task_sheet.dart';
import 'package:planz/Widgets/task_card.dart';
import 'package:planz/pages/deleted_pages.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/task_provider.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "User";

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> getName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc['name'] != null) {
        setState(() {
          name = doc['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the task provider and get active tasks only
    final allTasks = ref.watch(task_provider);
    final taskNotifier = ref.watch(task_provider.notifier);
    final activeTasks = taskNotifier.activeTasks;
    final todaysDeletedTasks = taskNotifier.todaysDeletedTasks;
    final len = activeTasks.length;
    String _searchquery = "";

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimal Header with Dustbin
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Text(
                      "PLANZ",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),

                    // Search button
                    GestureDetector(
                      onTap: () async {
                        final result = await showSearch<String>(
                          context: context,
                          delegate: TaskSearch(ref.read(task_provider)),
                        );
                        if (result != null) {
                          setState(() {
                            _searchquery = result;
                          });
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // Dustbin button with badge
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showDeletedTasksSheet();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: todaysDeletedTasks.isNotEmpty
                              ? Colors.red.shade50
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: todaysDeletedTasks.isNotEmpty
                                    ? Colors.red.shade600
                                    : Colors.grey.shade600,
                              ),
                            ),

                            // Badge for deleted tasks count
                            if (todaysDeletedTasks.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      todaysDeletedTasks.length > 9
                                          ? '9+'
                                          : todaysDeletedTasks.length
                                                .toString(),
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
                    ),
                  ],
                ),
              ),

              // Category Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Row(
                  children: [
                    _buildCategoryTab("All Tasks", len, true),
                    const SizedBox(width: 16),
                    _buildCategoryTab("Home", 0, false),
                    const SizedBox(width: 16),
                    _buildCategoryTab("Work", 0, false),
                  ],
                ),
              ),

              // Today Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${DateTime.now().day} ${_getMonthName(DateTime.now().month).toUpperCase()} ${_getDayName(DateTime.now().weekday).toUpperCase()}",
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
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Task List - Show only active tasks
              activeTasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: activeTasks.length,
                      itemBuilder: (context, index) {
                        final task = activeTasks[index];
                        return _buildTaskItem(
                          task.task,
                          task.desc,
                          false, // Tasks are not completed when displayed
                          () {
                            HapticFeedback.lightImpact();

                            // Find the original index in the full task list

                            final originalIndex = allTasks.indexOf(task);

                            // Delete the task (soft delete)
                            taskNotifier.deleteTask(originalIndex);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
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
                                        // Restore the task
                                        taskNotifier.restoreTask(originalIndex);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
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
                                backgroundColor: Colors.black87,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 4),
                              ),
                            );

                            if (activeTasks.length == 1) {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  _showCompletionSheet();
                                },
                              );
                            }
                          },
                          task.priority,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletedTasksSheet() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),

        // Simple message for now
        child: DeletedTasksSheet(),
      ),
    );
  }

  Widget _buildCategoryTab(String title, int count, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black87 : Colors.transparent,
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
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white24 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String subtitle,
    bool isCompleted,
    VoidCallback onTap,
    TaskPriority taskpriority,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // Add subtle background color based on priority
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: taskpriority.color.withOpacity(0.15),
          width: 1,
        ),
        // Add subtle shadow with priority color
        boxShadow: [
          BoxShadow(
            color: taskpriority.color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Light ray effect emanating from priority line
          Positioned(
            left: 5, // Start from the priority line width
            top: 0,
            bottom: 0,
            child: Container(
              width: 80, // Fixed width for the light ray effect
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(
                    40,
                  ), // Curved edge for natural light beam
                  bottomRight: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.3, 0.6, 1.0], // evenly spread
                  colors: [
                    taskpriority.color.withOpacity(
                      0.15,
                    ), // Strongest near start
                    taskpriority.color.withOpacity(0.10), // Medium
                    taskpriority.color.withOpacity(0.05), // Lighter
                    taskpriority.color.withOpacity(
                      0.0,
                    ), // Fully transparent at end
                  ],
                ),
              ),
            ),
          ),

          // Main task content
          IntrinsicHeight(
            child: Row(
              children: [
                // Priority line indicator (made slightly wider and more vibrant)
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: taskpriority.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    // Add subtle glow to the priority line
                    boxShadow: [
                      BoxShadow(
                        color: taskpriority.color.withOpacity(0.0),
                        blurRadius: 1,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Checkbox with priority color theme
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? taskpriority.color
                            : taskpriority.color.withOpacity(0.5),
                        width: 2,
                      ),
                      // Add subtle glow to checkbox
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: taskpriority.color.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Task content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isCompleted
                                ? Colors.grey.shade400
                                : Colors.black87,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
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

  Widget _buildEmptyState() {
    return Center(
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
              Icons.check_circle_outline,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No tasks for today",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enjoy your free time",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  void _showCompletionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "All tasks completed",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
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
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}

class TaskSearch extends SearchDelegate<String> {
  final List<Task> tasks;
  TaskSearch(this.tasks);
  @override
  String get searchFieldLabel => 'Search tasks';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, "");
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filtered_tasks = tasks
        .where((t) => t.task.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (filtered_tasks.isEmpty) {
      return Center(child: Text("No tasks found"));
    }

    return Container(
      color: const Color(0xFFFAFAFA),
      child: ListView.builder(
        itemCount: filtered_tasks.length,
        itemBuilder: (context, index) {
          final task = filtered_tasks[index];
          return ListTile(
            title: Text(task.task),
            subtitle: Text(task.desc ?? ""),
            onTap: () {
              close(context, task.task);
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = tasks
        .where((t) => t.task.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Container(
      color: const Color(0xFFFAFAFA),
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final task = suggestions[index];
          return ListTile(
            title: Text(task.task),
            subtitle: Text(task.desc ?? ""),
            onTap: () {
              query = task.task;
              showResults(context);
            },
          );
        },
      ),
    );
  }
}
