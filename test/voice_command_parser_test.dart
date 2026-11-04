import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planz/pages/voice_command_parser.dart';

void main() {
  // Wednesday, 4 Nov 2026, 10:00
  final now = DateTime(2026, 11, 4, 10);
  VoiceCommand parse(String s) => VoiceCommandParser.parseCommand(s, now: now);

  test('plain task is not scheduled', () {
    final c = parse('add task buy groceries');
    expect(c.taskTitle, 'Buy groceries');
    expect(c.isScheduled, isFalse);
    expect(c.scheduledDate, isNull);
  });

  test('words containing "at"/"on" do not trigger scheduling', () {
    final c = parse('fix phone and check what happened');
    expect(c.taskTitle, 'Fix phone and check what happened');
    expect(c.isScheduled, isFalse);
  });

  test('tomorrow at 3 pm', () {
    final c = parse('schedule meeting tomorrow at 3 pm');
    expect(c.taskTitle, 'Meeting');
    expect(c.scheduledDate, DateTime(2026, 11, 5));
    expect(c.scheduledTime, const TimeOfDay(hour: 15, minute: 0));
  });

  test('keeps minutes and handles "p.m."', () {
    final c = parse('call the bank at 3:30 p.m.');
    expect(c.taskTitle, 'Call the bank');
    expect(c.scheduledTime, const TimeOfDay(hour: 15, minute: 30));
    expect(c.scheduledDate, DateTime(2026, 11, 4)); // time only → today
  });

  test('remind me to ... on weekday', () {
    final c = parse('Remind me to call mom on Friday');
    expect(c.taskTitle, 'Call mom');
    expect(c.scheduledDate, DateTime(2026, 11, 6));
  });

  test('same weekday means next week', () {
    expect(parse('gym on wednesday').scheduledDate, DateTime(2026, 11, 11));
  });

  test('month and day, past dates roll to next year', () {
    final c = parse('dentist on december 15 at 10:30 am');
    expect(c.taskTitle, 'Dentist');
    expect(c.scheduledDate, DateTime(2026, 12, 15));
    expect(c.scheduledTime, const TimeOfDay(hour: 10, minute: 30));
    expect(parse('renew passport march 2').scheduledDate, DateTime(2027, 3, 2));
  });

  test('next week and 12 am', () {
    expect(parse('team sync next week').scheduledDate, DateTime(2026, 11, 11));
    expect(
      parse('backup at 12 am').scheduledTime,
      const TimeOfDay(hour: 0, minute: 0),
    );
  });

  test('invalid dates are ignored', () {
    expect(parse('party on february 31').scheduledDate, isNull);
  });
}
