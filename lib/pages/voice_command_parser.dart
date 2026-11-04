import 'package:flutter/material.dart';

class VoiceCommand {
  final String taskTitle;
  final String description;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final bool isScheduled;

  VoiceCommand({
    required this.taskTitle,
    this.description = '',
    this.scheduledDate,
    this.scheduledTime,
    this.isScheduled = false,
  });
}

/// Turns spoken text into a task, e.g.
///  - "add task buy groceries"                → "Buy groceries"
///  - "schedule meeting tomorrow at 3 pm"     → "Meeting", tomorrow 15:00
///  - "remind me to call mom on friday"       → "Call mom", next Friday
///  - "dentist on december 15 at 10:30 am"    → "Dentist", Dec 15 10:30
class VoiceCommandParser {
  static const _months = {
    'january': 1,
    'jan': 1,
    'february': 2,
    'feb': 2,
    'march': 3,
    'mar': 3,
    'april': 4,
    'apr': 4,
    'may': 5,
    'june': 6,
    'jun': 6,
    'july': 7,
    'jul': 7,
    'august': 8,
    'aug': 8,
    'september': 9,
    'sept': 9,
    'sep': 9,
    'october': 10,
    'oct': 10,
    'november': 11,
    'nov': 11,
    'december': 12,
    'dec': 12,
  };

  static const _weekdays = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  // Leading phrases that aren't part of the task itself (longest first).
  static const _prefixes = [
    'set a reminder to',
    'set reminder to',
    'remind me to',
    'remind me',
    'add a task to',
    'add task to',
    'add a task',
    'add task',
    'create a task',
    'create task',
    'new task',
    'schedule a',
    'schedule',
    'i need to',
    'i want to',
    'i have to',
    'add',
    'create',
    'task',
  ];

  // am/pm as spoken or transcribed: "pm", "p.m.", "p m"
  static const _ampm = r'(a\.?\s?m\.?|p\.?\s?m\.?)';

  static final _timeRe = RegExp(
    r'\b(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*' +
        _ampm +
        r'(?=\s|$)'
            r'|\bat\s+(\d{1,2})(?::(\d{2}))?\b',
    caseSensitive: false,
  );

  static final _monthRe = RegExp(
    r'\b(?:on\s+)?(?:the\s+)?(' +
        _months.keys.join('|') +
        r')\s+(\d{1,2})(?:st|nd|rd|th)?\b',
    caseSensitive: false,
  );

  static final _slashDateRe = RegExp(r'\b(?:on\s+)?(\d{1,2})/(\d{1,2})\b');

  static final _weekdayRe = RegExp(
    r'\b(?:on\s+|next\s+|this\s+)?(' + _weekdays.keys.join('|') + r')\b',
    caseSensitive: false,
  );

  static final _relativeDayRe = RegExp(
    r'\b(today|tonight|tomorrow|day after tomorrow|next week)\b',
    caseSensitive: false,
  );

  static VoiceCommand parseCommand(String spokenText, {DateTime? now}) {
    now ??= DateTime.now();
    var text = spokenText.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

    final time = _extractTime(text);
    final date = _extractDate(text, now);

    // Strip the date/time phrases so they don't end up in the title.
    for (final re in [
      _timeRe,
      _monthRe,
      _slashDateRe,
      _weekdayRe,
      _relativeDayRe,
    ]) {
      text = text.replaceAll(re, ' ');
    }

    // A time alone means "today at that time".
    final scheduledDate =
        date ?? (time != null ? DateTime(now.year, now.month, now.day) : null);

    return VoiceCommand(
      taskTitle: _cleanTitle(text),
      scheduledDate: scheduledDate,
      scheduledTime: time,
      isScheduled: scheduledDate != null,
    );
  }

  static String _cleanTitle(String text) {
    var t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    for (final p in _prefixes) {
      if (t == p || t.startsWith('$p ')) {
        t = t.substring(p.length).trim();
        break;
      }
    }
    // Dangling connectors left behind after removing dates/times.
    t = t.replaceAll(RegExp(r'\b(on|at|by|for|the)$'), '').trim();
    if (t.startsWith('to ')) t = t.substring(3).trim();
    if (t.isEmpty) return 'Voice Task';
    return t[0].toUpperCase() + t.substring(1);
  }

  static TimeOfDay? _extractTime(String text) {
    final m = _timeRe.firstMatch(text);
    if (m != null) {
      final explicit = m.group(1) != null;
      var hour = int.parse(explicit ? m.group(1)! : m.group(4)!);
      final minute =
          int.tryParse((explicit ? m.group(2) : m.group(5)) ?? '') ?? 0;
      final ampm = explicit
          ? m.group(3)!.replaceAll(RegExp(r'[.\s]'), '')
          : null;

      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;
      // "at 7" with no am/pm: assume a working-hours reading (1–7 → pm).
      if (ampm == null && hour >= 1 && hour <= 7) hour += 12;

      if (hour <= 23 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    if (RegExp(r'\btonight\b').hasMatch(text)) {
      return const TimeOfDay(hour: 20, minute: 0);
    }
    return null;
  }

  static DateTime? _extractDate(String text, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    final rel = _relativeDayRe.firstMatch(text);
    if (rel != null) {
      switch (rel.group(1)) {
        case 'today':
        case 'tonight':
          return today;
        case 'tomorrow':
          return today.add(const Duration(days: 1));
        case 'day after tomorrow':
          return today.add(const Duration(days: 2));
        case 'next week':
          return today.add(const Duration(days: 7));
      }
    }

    final month = _monthRe.firstMatch(text);
    if (month != null) {
      final date = _futureDate(
        today,
        _months[month.group(1)!]!,
        int.parse(month.group(2)!),
      );
      if (date != null) return date;
    }

    final slash = _slashDateRe.firstMatch(text);
    if (slash != null) {
      final date = _futureDate(
        today,
        int.parse(slash.group(1)!),
        int.parse(slash.group(2)!),
      );
      if (date != null) return date;
    }

    final weekday = _weekdayRe.firstMatch(text);
    if (weekday != null) {
      final target = _weekdays[weekday.group(1)!]!;
      var days = (target - today.weekday) % 7;
      if (days == 0) days = 7; // "on monday" said on a Monday → next week
      return today.add(Duration(days: days));
    }

    return null;
  }

  /// The next occurrence of month/day on or after [today]; null if invalid.
  static DateTime? _futureDate(DateTime today, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    var date = DateTime(today.year, month, day);
    if (date.month != month) return null; // e.g. Feb 31
    if (date.isBefore(today)) date = DateTime(today.year + 1, month, day);
    return date;
  }
}
