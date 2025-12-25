import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:planz/Widgets/bottom_task_sheet.dart';
import 'package:planz/pages/Home.dart';
import 'package:planz/pages/List.dart';
import 'package:planz/pages/Profile.dart';
import 'package:planz/pages/Schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/task_provider.dart';
class PageNave extends ConsumerStatefulWidget {
  const PageNave({super.key});

  @override
  ConsumerState<PageNave> createState() => _PageNaveState();
}

class _PageNaveState extends ConsumerState<PageNave> {
  // Updated method to handle priority
  void onTaskCreated(
    String task,
    String desc,
    TaskPriority priority,
    DateTime? scheduledate,
    TimeOfDay? scheduletime,
  ) {
    if (task.isNotEmpty) {
      ref
          .read(task_provider.notifier)
          .addTask(
            task,
            desc,
            priority,
            scheduledate: scheduledate,
            scheduletime: scheduletime,
          ); // Now includes priority
      setState(() {
        _selectedIndex = scheduledate != null
            ? 1
            : 2; // optional: switch to Lists tab after creation
      });
    }
  }

  int _selectedIndex = 0;

  void _OnItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = [
      HomeScreen(),
      SChedulePage(),
      ListPage(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.home, "Home", 0),
              _buildNavItem(Icons.event_note, "Plan", 1),
              _buildAddButton(),
              _buildNavItem(Icons.list_alt, "Lists", 2),
              _buildNavItem(Icons.account_circle, "Profile", 3),
            ],
          ),
        ),
      ),
      body: list[_selectedIndex],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _OnItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
  return GestureDetector(
    onTap: () async {
      HapticFeedback.mediumImpact();
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: Colors.black.withOpacity(0.3),
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: bottom_sheet(),
        ),
      );

      if (result != null) {
        final task = result["task"] ?? "";
        final desc = result["desc"] ?? "";
        final priority = result["priority"] ?? TaskPriority.medium;
        final date = result["date"] as DateTime?;
        final time = result["time"] as TimeOfDay?;

        // DEBUG: Print what we received
        print("DEBUG: Received from bottom sheet:");
        print("Task: $task");
        print("Desc: $desc");
        print("Priority: $priority");
        print("Date: $date");
        print("Time: $time");

        // Only create task if title is provided
        if (task.isNotEmpty) {
          // FIXED - Always pass scheduling parameters
          ref.read(task_provider.notifier).addTask(
            task,
            desc,
            priority,
            scheduledate: date, // Pass the date
            scheduletime: time, // Pass the time
          );

          // DEBUG: Check if task was added
          final allTasks = ref.read(task_provider);
          print("DEBUG: Total tasks after adding: ${allTasks.length}");
          if (allTasks.isNotEmpty) {
            final lastTask = allTasks.last;
            print("DEBUG: Last task - Title: ${lastTask.task}");
            print("DEBUG: Last task - Schedule Date: ${lastTask.scheduledate}");
            print("DEBUG: Last task - Schedule Time: ${lastTask.scheduletime}");
            print("DEBUG: Last task - Is Scheduled: ${lastTask.isscheduled}");
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      date != null
                          ? "Task scheduled for ${date.day}/${date.month}/${date.year}"
                          : "Task created successfully",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to appropriate tab
          setState(() {
            _selectedIndex = date != null ? 1 : 0; // Schedule tab if date, else Home
          });
        }
      } else {
        print("DEBUG: Result from bottom sheet was null");
      }
    },
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 20),
    ),
  );
}
}
