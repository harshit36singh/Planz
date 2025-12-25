import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class VoiceCommandParser {
  static VoiceCommand parseCommand(String spokenText) {
    final text = spokenText.toLowerCase().trim();
    
    // Check if it's a scheduling command
    final isScheduleCommand = _isScheduleCommand(text);
    
    if (!isScheduleCommand) {
      // Simple task creation
      return VoiceCommand(
        taskTitle: _extractTaskTitle(text),
        description: '',
        isScheduled: false,
      );
    }
    
    // Parse scheduled task
    final taskTitle = _extractScheduledTaskTitle(text);
    final date = _extractDate(text);
    final time = _extractTime(text);
    
    return VoiceCommand(
      taskTitle: taskTitle,
      scheduledDate: date,
      scheduledTime: time,
      isScheduled: true,
    );
  }
  
  static bool _isScheduleCommand(String text) {
    final scheduleKeywords = [
      'schedule', 'add', 'remind me', 'set reminder',
      'at', 'on', 'tomorrow', 'today', 'next week'
    ];
    
    return scheduleKeywords.any((keyword) => text.contains(keyword));
  }
  
  static String _extractTaskTitle(String text) {
    // Remove common prefixes
    final prefixes = [
      'add task', 'create task', 'new task', 'task',
      'add', 'create', 'make', 'i need to', 'i want to'
    ];
    
    String cleaned = text;
    for (final prefix in prefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
        break;
      }
    }
    
    return cleaned.isEmpty ? 'Voice Task' : _capitalize(cleaned);
  }
  
  static String _extractScheduledTaskTitle(String text) {
    // Extract task title from scheduling commands
    String taskTitle = text;
    
    // Remove scheduling prefixes
    final schedulePrefixes = [
      'schedule', 'add', 'remind me to', 'set reminder to',
      'remind me', 'set reminder'
    ];
    
    for (final prefix in schedulePrefixes) {
      if (taskTitle.startsWith(prefix)) {
        taskTitle = taskTitle.substring(prefix.length).trim();
        break;
      }
    }
    
    // Remove date/time suffixes
    final dateTimePatterns = [
      r'\s+at\s+\d+',           // "at 3"
      r'\s+at\s+\d+:\d+',       // "at 3:30"
      r'\s+on\s+\w+',           // "on monday"
      r'\s+tomorrow',           // "tomorrow"
      r'\s+today',              // "today"
      r'\s+next\s+week',        // "next week"
    ];
    
    for (final pattern in dateTimePatterns) {
      taskTitle = taskTitle.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }
    
    return taskTitle.trim().isEmpty ? 'Voice Task' : _capitalize(taskTitle.trim());
  }
  
  static DateTime? _extractDate(String text) {
  final now = DateTime.now();
  
  // Today
  if (text.contains('today')) {
    return DateTime(now.year, now.month, now.day);
  }
  
  // Tomorrow
  if (text.contains('tomorrow')) {
    final tomorrow = now.add(Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }
  
  // Month and day parsing (e.g., "December 15", "Dec 15", "12/15")
  final monthDate = _parseMonthAndDay(text, now);
  if (monthDate != null) {
    return monthDate;
  }
  
  // Day of week (next occurrence)
  final weekdays = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };
  
  for (final entry in weekdays.entries) {
    if (text.contains(entry.key)) {
      return _getNextWeekday(now, entry.value);
    }
  }
  
  // Default to today if no date specified but it's a schedule command
  if (_isScheduleCommand(text)) {
    return DateTime(now.year, now.month, now.day);
  }
  
  return null;
}

static DateTime? _parseMonthAndDay(String text, DateTime now) {
  // Month names mapping
  final months = {
    'january': 1, 'jan': 1,
    'february': 2, 'feb': 2,
    'march': 3, 'mar': 3,
    'april': 4, 'apr': 4,
    'may': 5,
    'june': 6, 'jun': 6,
    'july': 7, 'jul': 7,
    'august': 8, 'aug': 8,
    'september': 9, 'sep': 9, 'sept': 9,
    'october': 10, 'oct': 10,
    'november': 11, 'nov': 11,
    'december': 12, 'dec': 12,
  };
  
  // Pattern 1: "Month Day" (e.g., "December 15", "Dec 15")
  for (final entry in months.entries) {
    final pattern = RegExp(r'\b' + entry.key + r'\s+(\d{1,2})\b', caseSensitive: false);
    final match = pattern.firstMatch(text);
    if (match != null) {
      try {
        final day = int.parse(match.group(1)!);
        final month = entry.value;
        
        if (day >= 1 && day <= 31) {
          // Determine the year (current year or next year)
          var year = now.year;
          final targetDate = DateTime(year, month, day);
          
          // If the date has already passed this year, schedule for next year
          if (targetDate.isBefore(DateTime(now.year, now.month, now.day))) {
            year = now.year + 1;
          }
          
          return DateTime(year, month, day);
        }
      } catch (e) {
        // Continue if parsing fails
      }
    }
  }
  
  // Pattern 2: "MM/DD" or "M/D" format
  final slashPattern = RegExp(r'\b(\d{1,2})/(\d{1,2})\b');
  final slashMatch = slashPattern.firstMatch(text);
  if (slashMatch != null) {
    try {
      final month = int.parse(slashMatch.group(1)!);
      final day = int.parse(slashMatch.group(2)!);
      
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        var year = now.year;
        final targetDate = DateTime(year, month, day);
        
        // If the date has already passed this year, schedule for next year
        if (targetDate.isBefore(DateTime(now.year, now.month, now.day))) {
          year = now.year + 1;
        }
        
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Continue if parsing fails
    }
  }
  
  return null;
}
  
  static TimeOfDay? _extractTime(String text) {
    // Match patterns like "at 3", "at 3:30", "at 15:30"
    final timePatterns = [
      RegExp(r'at\s+(\d{1,2}):(\d{2})', caseSensitive: false),  // "at 3:30"
      RegExp(r'at\s+(\d{1,2})\s*(am|pm)', caseSensitive: false), // "at 3 pm"
      RegExp(r'at\s+(\d{1,2})', caseSensitive: false),          // "at 3"
    ];
    
    for (final pattern in timePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int hour = int.parse(match.group(1)!);
          int minute = 0;
          
          // Handle minutes if present
          if (match.groupCount >= 2 && match.group(2) != null) {
            if (match.group(2)!.contains(':')) {
              // This shouldn't happen with our regex, but just in case
              minute = int.parse(match.group(2)!);
            } else {
              // AM/PM handling
              final ampm = match.group(2)!.toLowerCase();
              if (ampm == 'pm' && hour != 12) hour += 12;
              if (ampm == 'am' && hour == 12) hour = 0;
            }
          } else if (match.groupCount >= 2 && match.group(2) != null) {
            minute = int.parse(match.group(2)!);
          }
          
          // Default to PM for afternoon hours if no AM/PM specified
          if (hour >= 1 && hour <= 11 && !text.contains('am') && !text.contains('pm')) {
            final now = DateTime.now();
            if (now.hour >= 12) hour += 12; // Assume PM if it's afternoon
          }
          
          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        } catch (e) {
          // Continue to next pattern if parsing fails
        }
      }
    }
    
    return null;
  }
  
  static DateTime _getNextWeekday(DateTime from, int weekday) {
    final daysUntilTarget = (weekday - from.weekday) % 7;
    final targetDate = from.add(Duration(days: daysUntilTarget == 0 ? 7 : daysUntilTarget));
    return DateTime(targetDate.year, targetDate.month, targetDate.day);
  }
  
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}