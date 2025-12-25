import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planz/providers/task_provider.dart';
import 'package:planz/providers/task_notifier.dart';

class SChedulePage extends ConsumerStatefulWidget {
  const SChedulePage({super.key});

  @override
  ConsumerState<SChedulePage> createState() => _SChedulePageState();
}

class _SChedulePageState extends ConsumerState<SChedulePage> {
  DateTime? selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentHour();
    });
  }

  void _scrollToCurrentHour() {
    if (selectedDate != null && isSameDay(selectedDate, DateTime.now())) {
      final now = DateTime.now();
      final hourIndex = now.hour;
      final offset = hourIndex * 80.0; // Adjusted for new height
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Future<void> showCustomCalendar(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 80,
          ),
          child: SingleChildScrollView(
            child: CustomCalendarDialog(
              initialDate: selectedDate ?? DateTime.now(),
              focusedDate: focusedDate,
            ),
          ),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        focusedDate = picked;
      });
      _scrollToCurrentHour();
    }
  }

  // Helper method to get tasks for a specific hour
  List<Task> _getTasksForHour(List<Task> dayTasks, int hour) {
  return dayTasks.where((task) {
    // If task has no time, show it in the first hour (12:00 AM)
    if (task.scheduletime == null) return hour == 9;
    return task.scheduletime!.hour == hour;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime displayDate = selectedDate ?? now;

    // Watch tasks for the selected date
    final dayTasks = selectedDate != null
        ? ref.watch(tasksForDateProvider(selectedDate!))
        : <Task>[];

    print("DEBUG Schedule: Selected date: $selectedDate");
    print("DEBUG Schedule: Day tasks found: ${dayTasks.length}");
    for (var task in dayTasks) {
      print(
        "DEBUG Schedule: Task '${task.task}' - Date: ${task.scheduledate}, Time: ${task.scheduletime}",
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and time - matching homepage
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with date + clock
                Row(
                  children: [
                    Text(
                      "${displayDate.day}",
                      style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getMonthName(displayDate.month),
                      style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showCustomCalendar(context),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 28,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(
                        const Duration(seconds: 1),
                        (_) => DateTime.now(),
                      ),
                      initialData: DateTime.now(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final formatted = DateFormat(
                          'hh:mm:ss a',
                        ).format(snapshot.data!);
                        return Text(
                          formatted,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${displayDate.year}",
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Calendar week view
                TableCalendar(
                  focusedDay: focusedDate,
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (day, focus) {
                    setState(() {
                      selectedDate = day;
                      focusedDate = focus;
                    });
                    _scrollToCurrentHour();
                  },
                  headerVisible: false,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black87, width: 2),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: GoogleFonts.inter(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: GoogleFonts.inter(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    defaultTextStyle: GoogleFonts.inter(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    outsideTextStyle: GoogleFonts.inter(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Divider line - matching homepage
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 24),

          // Timeline hours after selecting a date
          if (selectedDate != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSameDay(selectedDate, now)
                              ? "Today's Schedule"
                              : "${_getMonthName(selectedDate!.month)} ${selectedDate!.day} Schedule",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (dayTasks.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${dayTasks.length} task${dayTasks.length != 1 ? 's' : ''}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: 24,
                        itemBuilder: (context, index) {
                          final time = DateFormat('hh:00 a').format(
                            DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                              index,
                            ),
                          );

                          // Get tasks for this hour
                          final hourTasks = _getTasksForHour(dayTasks, index);

                          // Check if this is the current hour
                          final isCurrentHour =
                              isSameDay(selectedDate, now) && index == now.hour;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCurrentHour
                                  ? Colors.black87.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentHour
                                    ? Colors.black87.withOpacity(0.2)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 70,
                                  child: Text(
                                    time,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isCurrentHour
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: hourTasks.isEmpty
                                      ? Container(
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              "No events scheduled",
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade400,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: hourTasks.map((task) {
                                            final taskIndex = ref
                                                .read(task_provider)
                                                .indexOf(task);
                                            return _buildScheduledTaskItem(
                                              task,
                                              taskIndex,
                                            );
                                          }).toList(),
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
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
                          Icons.calendar_today_outlined,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Select a date",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Choose a date from the calendar\nto view your schedule",
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduledTaskItem(Task task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.priority.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.priority.color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Priority indicator
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: task.priority.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Checkbox
          GestureDetector(
            onTap: () =>
                ref.read(task_provider.notifier).toggleTaskCompletion(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted
                    ? task.priority.color
                    : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted
                      ? task.priority.color
                      : task.priority.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.task,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted
                        ? Colors.grey.shade400
                        : Colors.black87,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                if (task.scheduletime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.scheduletime!.format(context),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the existing CustomCalendarDialog class exactly as it was
class CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime focusedDate;

  const CustomCalendarDialog({
    super.key,
    required this.initialDate,
    required this.focusedDate,
  });

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime selectedDate;
  late DateTime focusedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    focusedDate = widget.focusedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Full month calendar
            TableCalendar(
              focusedDay: focusedDate,
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (day, focus) {
                setState(() {
                  selectedDate = day;
                  focusedDate = focus;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  focusedDate = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.grey.shade600,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                ),
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                weekendStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              calendarStyle: CalendarStyle(
                // Today's styling
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.black87, width: 2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: GoogleFonts.inter(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),

                // Selected day styling
                selectedDecoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),

                // Default day styling
                defaultTextStyle: GoogleFonts.inter(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),

                // Weekend styling
                weekendTextStyle: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),

                // Outside days styling
                outsideTextStyle: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),

                // Cell styling
                cellMargin: const EdgeInsets.all(4),
                cellPadding: const EdgeInsets.all(0),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Select',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
