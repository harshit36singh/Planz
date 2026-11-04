import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planz/Widgets/bottom_task_sheet.dart';
import 'package:planz/pages/Home.dart';
import 'package:planz/pages/List.dart';
import 'package:planz/pages/Profile.dart';
import 'package:planz/pages/Schedule.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/task_provider.dart';
import 'package:planz/providers/theme_provider.dart';

/// Opens the task bottom sheet. Pass [task] to edit an existing task.
Future<Map<String, dynamic>?> showTaskSheet(
  BuildContext context, {
  Task? task,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: Colors.black.withValues(alpha: 0.3),
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: bottom_sheet(initialTask: task),
    ),
  );
}

class PageNave extends ConsumerStatefulWidget {
  const PageNave({super.key});

  @override
  ConsumerState<PageNave> createState() => _PageNaveState();
}

class _PageNaveState extends ConsumerState<PageNave> {
  int _selectedIndex = 0;

  /// Date the Schedule tab should open on (set after scheduling a task).
  DateTime _scheduleDate = DateTime.now();

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      // Reopening the Plan tab from the nav bar starts on today again.
      if (index == 1 && _selectedIndex != 1) _scheduleDate = DateTime.now();
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      SChedulePage(key: ValueKey(_scheduleDate), initialDate: _scheduleDate),
      const ListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
      body: pages[_selectedIndex],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final accent = AppTheme.getTextColor(context);
    final onAccent = AppTheme.getCardColor(context);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? onAccent
                  : AppTheme.getSecondaryTextColor(context),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    HapticFeedback.mediumImpact();
    final result = await showTaskSheet(context);
    if (result == null || !mounted) return;

    final String task = result["task"] ?? "";
    if (task.isEmpty) return;
    final date = result["date"] as DateTime?;

    ref
        .read(taskProvider.notifier)
        .addTask(
          task,
          result["desc"] ?? "",
          result["priority"] ?? TaskPriority.medium,
          scheduledate: date,
          scheduletime: result["time"] as TimeOfDay?,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          date != null
              ? "Task scheduled for ${date.day}/${date.month}/${date.year}"
              : "Task created successfully",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // Scheduled tasks: jump to the Plan tab on that day. Otherwise Home.
    setState(() {
      if (date != null) {
        _scheduleDate = date;
        _selectedIndex = 1;
      } else {
        _selectedIndex = 0;
      }
    });
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _createTask,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.getTextColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.add, color: AppTheme.getCardColor(context), size: 20),
      ),
    );
  }
}
