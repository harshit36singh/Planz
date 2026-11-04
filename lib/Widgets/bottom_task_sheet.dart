import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:planz/pages/voice.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/theme_provider.dart';

/// Bottom sheet for creating a task (List / Schedule / Voice tabs) or, when
/// [initialTask] is given, editing an existing one.
///
/// Pops with a map: {task, desc, priority, date, time} (plus `id` when editing).
class bottom_sheet extends StatefulWidget {
  final Task? initialTask;
  const bottom_sheet({super.key, this.initialTask});

  @override
  State<bottom_sheet> createState() => _bottom_sheetState();
}

class _bottom_sheetState extends State<bottom_sheet> {
  final TextEditingController tasktitle = TextEditingController();
  final TextEditingController desc = TextEditingController();
  String? selectdebtn = "List";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TaskPriority selectedPriority = TaskPriority.medium;

  bool get isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    if (t != null) {
      tasktitle.text = t.task;
      desc.text = t.desc;
      selectedDate = t.scheduledate;
      selectedTime = t.scheduletime;
      selectedPriority = t.priority;
      selectdebtn = t.isscheduled ? "Schedule" : "List";
    }
    // Rebuild so the create button enables/disables as the title changes.
    tasktitle.addListener(_onTitleChanged);
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    tasktitle.removeListener(_onTitleChanged);
    tasktitle.dispose();
    desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = selectedDate != null && selectedDate!.isBefore(today);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      // Allow keeping an existing past date when editing.
      firstDate: isPast ? selectedDate! : today,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(
        () => selectedDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                bottomsheetheader(),
                const SizedBox(height: 20),
                // Tab buttons
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: boxchk("List", Icons.assignment_outlined),
                      ),
                      Expanded(
                        child: boxchk(
                          "Schedule",
                          Icons.calendar_month_outlined,
                        ),
                      ),
                      // Voice input only makes sense for new tasks.
                      if (!isEditing)
                        Expanded(child: boxchk("Voice", Icons.mic_outlined)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content changes depending on selected button
                Expanded(child: buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    final btn = selectdebtn ?? "List";

    if (btn == "List") {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Task Title",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            field("I want to...", null, false, tasktitle),
            const SizedBox(height: 16),
            Text(
              "Task Description",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            field("Description (optional)", null, false, desc),
            const SizedBox(height: 25),
            buildPrioritySelector(),
            const SizedBox(height: 25),
            Text(
              "Additional Options",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                dotted_field(
                  text: selectedDate == null
                      ? "Due Date"
                      : "Due ${_formatDate(selectedDate!)}",
                  icon: Icons.calendar_today_outlined,
                  tap: _pickDate,
                ),
                if (selectedDate != null)
                  dotted_field(
                    text: "Clear date",
                    icon: Icons.close,
                    tap: () => setState(() {
                      selectedDate = null;
                      selectedTime = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            buildCreateButton(),
          ],
        ),
      );
    } else if (btn == "Schedule") {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedule Task",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create a task with specific date and time",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Task Title",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            field("I want to...", null, false, tasktitle),
            const SizedBox(height: 16),
            Text(
              "Task Description",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            field("Description (optional)", null, false, desc),
            const SizedBox(height: 20),
            Text(
              "Date",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? "Select Date"
                          : _formatDate(selectedDate!),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: selectedDate == null
                            ? Colors.grey.shade400
                            : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Time",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showCupertinoTimePicker(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime == null
                          ? "Select Time"
                          : selectedTime!.format(context),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: selectedTime == null
                            ? Colors.grey.shade400
                            : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildPrioritySelector(),
            const SizedBox(height: 24),
            buildCreateButton(),
          ],
        ),
      );
    } else if (btn == "Voice") {
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Voice Input",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap to record your task using voice",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            Flexible(child: VoiceTask(priority: selectedPriority)),

            const SizedBox(height: 16),
            buildPrioritySelector(),
          ],
        ),
      );
    }

    return Container();
  }

  Widget buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Priority",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TaskPriority.values.map((priority) {
            final isSelected = selectedPriority == priority;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPriority = priority;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? priority.color.withValues(alpha: 0.0)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: priority.color.withValues(alpha: 0.6),
                            blurRadius: 29,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                          BoxShadow(
                            color: priority.color.withValues(alpha: 0.3),
                            blurRadius: 29,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ]
                      : [],
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isSelected ? 18 : 14,
                  height: isSelected ? 18 : 14,
                  decoration: BoxDecoration(
                    color: priority.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: priority.color.withValues(alpha: 0.5),
                        blurRadius: isSelected ? 8 : 4,
                        spreadRadius: isSelected ? 1 : 0,
                        offset: const Offset(0, 2),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: priority.color.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 3,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget buildCreateButton() {
    final isScheduleMode = selectdebtn == "Schedule";
    final canCreate = tasktitle.text.trim().isNotEmpty;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: canCreate
            ? () {
                Navigator.pop(context, {
                  if (isEditing) "id": widget.initialTask!.id,
                  "task": tasktitle.text.trim(),
                  "desc": desc.text.trim(),
                  "priority": selectedPriority,
                  "date": selectedDate,
                  // A time without a date can't be placed on the schedule.
                  "time": selectedDate == null ? null : selectedTime,
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black87,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          isEditing
              ? "Save Changes"
              : isScheduleMode
              ? "Schedule Task"
              : "Create Task",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget boxchk(String s, IconData i) {
    final isSel = selectdebtn == s;
    return Container(
      margin: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectdebtn = s;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? Colors.black87 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  i,
                  size: 16,
                  color: isSel ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  s,
                  style: GoogleFonts.inter(
                    color: isSel ? Colors.white : Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCupertinoTimePicker() {
    DateTime initialTime = DateTime.now();
    // Tracks the wheel; only committed to state when "Done" is tapped.
    TimeOfDay pending = selectedTime ?? TimeOfDay.fromDateTime(initialTime);
    if (selectedTime != null) {
      initialTime = DateTime(
        initialTime.year,
        initialTime.month,
        initialTime.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Text(
                        "Select Time",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => selectedTime = pending);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Done",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialTime,
                use24hFormat: false,
                onDateTimeChanged: (DateTime newTime) {
                  pending = TimeOfDay.fromDateTime(newTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget field(String s, Icon? i, bool t, TextEditingController tc) {
  return Builder(
    builder: (context) => Container(
      child: TextField(
        controller: tc,
        obscureText: t,
        keyboardType: t ? TextInputType.text : TextInputType.text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppTheme.getTextColor(context),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          hintText: s,
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: i,
          contentPadding: i == null
              ? const EdgeInsets.symmetric(vertical: 14, horizontal: 16)
              : const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    ),
  );
}

Widget bottomsheetheader() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Widget dotted_field({required String text, VoidCallback? tap, IconData? icon}) {
  return Builder(
    builder: (context) => GestureDetector(
      onTap: tap,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(8),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
