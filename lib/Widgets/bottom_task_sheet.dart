import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:planz/pages/voice.dart';
import 'package:planz/providers/task_notifier.dart';

class bottom_sheet extends StatefulWidget {
  const bottom_sheet({super.key});

  @override
  State<bottom_sheet> createState() => _bottom_sheetState();
}

class _bottom_sheetState extends State<bottom_sheet> {
  final TextEditingController tasktitle = TextEditingController();
  final TextEditingController desc = TextEditingController();
  bool isSel = false;
  String? selectdebtn = "List";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TaskPriority selectedPriority = TaskPriority.medium;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                    border: Border.all(color: Colors.grey.shade200, width: 1),
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
                color: Colors.black87,
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
                color: Colors.black87,
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
                dotted_field(text: "Inbox", icon: Icons.inbox_outlined),
                dotted_field(
                  text: "Due Date",
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
            buildCreateButton(),
          ],
        ),
      );
    } 
    else if (btn == "Schedule") {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedule Task",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
                color: Colors.black87,
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
                color: Colors.black87,
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 1)),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.black87,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => selectedDate = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                  ));
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
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
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showCupertinoTimePicker(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
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
    } 
    else if (selectdebtn == "Voice") {
      // FIXED: Remove SingleChildScrollView and Expanded conflict
      return Container(
         color: Colors.white,
    width: double.infinity,
    height: MediaQuery.of(context).size.height, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Voice Input",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
            
            // Voice widget takes remaining space without Expanded
            Flexible(
              child: VoiceTask(priority: selectedPriority),
            ),
            
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
            color: Colors.black87,
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
                      ? priority.color.withOpacity(0.0)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: priority.color.withOpacity(0.6),
                            blurRadius: 29,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                          BoxShadow(
                            color: priority.color.withOpacity(0.3),
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
                        color: priority.color.withOpacity(0.5),
                        blurRadius: isSelected ? 8 : 4,
                        spreadRadius: isSelected ? 1 : 0,
                        offset: const Offset(0, 2),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: priority.color.withOpacity(0.3),
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
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, {
            "task": tasktitle.text.trim(),
            "desc": desc.text.trim(),
            "priority": selectedPriority,
            "date": selectedDate,
            "time": selectedTime,
          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: canCreate ? Colors.black87 : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          isScheduleMode ? "Schedule Task" : "Create Task",
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
        decoration: const BoxDecoration(
          color: Colors.white,
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
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Done",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
                  setState(() {
                    selectedTime = TimeOfDay(
                      hour: newTime.hour,
                      minute: newTime.minute,
                    );
                  });
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
  return Container(
    child: TextField(
      controller: tc,
      obscureText: t,
      keyboardType: t ? TextInputType.text : TextInputType.text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
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
  return GestureDetector(
    onTap: tap ?? () => print("Tapped"),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
  );
}